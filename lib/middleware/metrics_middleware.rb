# Middleware for automatic HTTP request timing and metrics collection
class MetricsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    start_time = Time.current
    request = ActionDispatch::Request.new(env)
    
    # Skip metrics collection for certain paths to avoid noise
    if skip_metrics?(request.path)
      return @app.call(env)
    end

    status, headers, response = @app.call(env)
    
    # Calculate request duration in milliseconds
    duration = ((Time.current - start_time) * 1000).round(2)
    
    # Extract relevant request information
    endpoint = extract_endpoint(request)
    method = request.method
    user_agent = request.user_agent
    
    # Record the HTTP request metric
    MetricsCollector.record_request_time(
      duration,
      endpoint,
      {
        method: method,
        status: status,
        user_agent: user_agent&.truncate(100),
        remote_ip: request.remote_ip
      }
    )
    
    # Record additional HTTP metrics
    record_http_status_metric(status)
    record_response_size_metric(response, headers)
    
    [status, headers, response]
  rescue => e
    # Log error but don't break the request
    LoggingService.log_event(:error, "MetricsMiddleware error: #{e.message}", 
                              { error: e.class.name, path: request&.path })
    @app.call(env)
  end

  private

  def skip_metrics?(path)
    # Skip metrics for assets, health checks, and other non-business logic paths
    skip_patterns = [
      %r{^/assets/},
      %r{^/health},
      %r{^/up},
      %r{^/rails/},
      %r{^/favicon\.ico},
      %r{^/robots\.txt}
    ]
    
    skip_patterns.any? { |pattern| path.match?(pattern) }
  end

  def extract_endpoint(request)
    # Try to get the Rails route pattern, fallback to path
    if request.env['action_dispatch.request.path_parameters']
      controller = request.env['action_dispatch.request.path_parameters'][:controller]
      action = request.env['action_dispatch.request.path_parameters'][:action]
      
      if controller && action
        return "#{controller}##{action}"
      end
    end
    
    # Fallback to normalized path (remove IDs and other dynamic segments)
    normalize_path(request.path)
  end

  def normalize_path(path)
    # Replace numeric IDs and UUIDs with placeholders for better grouping
    path.gsub(%r{/\d+}, '/:id')
        .gsub(%r{/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}}, '/:uuid')
        .gsub(%r{/[a-zA-Z0-9_-]{20,}}, '/:token')
  end

  def record_http_status_metric(status)
    status_category = case status
                     when 200..299 then '2xx'
                     when 300..399 then '3xx'
                     when 400..499 then '4xx'
                     when 500..599 then '5xx'
                     else 'unknown'
                     end

    MetricsCollector.record_custom_metric(
      'http.response.status',
      1,
      { status: status, category: status_category }
    )
  end

  def record_response_size_metric(response, headers)
    content_length = headers['Content-Length']
    
    if content_length
      MetricsCollector.record_custom_metric(
        'http.response.size',
        content_length.to_i,
        { unit: 'bytes' }
      )
    elsif response.respond_to?(:body) && response.body.respond_to?(:bytesize)
      # Calculate size from response body if Content-Length not set
      size = response.body.sum(&:bytesize) rescue 0
      MetricsCollector.record_custom_metric(
        'http.response.size',
        size,
        { unit: 'bytes', calculated: true }
      )
    end
  end
end