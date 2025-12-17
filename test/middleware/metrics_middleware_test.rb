require "test_helper"

class MetricsMiddlewareTest < ActiveSupport::TestCase
  def setup
    @app = ->(env) { [200, { 'Content-Type' => 'text/html' }, ['Hello World']] }
    @middleware = MetricsMiddleware.new(@app)
  end

  test "should record HTTP request metrics" do
    env = Rack::MockRequest.env_for('/test')
    
    initial_count = Metric.count
    
    @middleware.call(env)
    
    # Should have recorded request time metric
    assert Metric.count > initial_count, "Should have recorded metrics"
    assert Metric.where(name: 'http.request.duration').exists?, "Should record request duration"
  end

  test "should skip metrics for asset paths" do
    env = Rack::MockRequest.env_for('/assets/application.css')
    
    initial_count = Metric.count
    
    @middleware.call(env)
    
    # Should not have recorded metrics for assets
    assert_equal initial_count, Metric.count, "Should not record metrics for assets"
  end

  test "should skip metrics for health check paths" do
    env = Rack::MockRequest.env_for('/health')
    
    initial_count = Metric.count
    
    @middleware.call(env)
    
    # Should not have recorded metrics for health checks
    assert_equal initial_count, Metric.count, "Should not record metrics for health checks"
  end

  test "should record status code metrics" do
    env = Rack::MockRequest.env_for('/test')
    
    @middleware.call(env)
    
    # Should have recorded status metric
    assert Metric.where("name = 'app.http.response.status' AND tags LIKE '%\"status\":200%'").exists?,
           "Should record status code metric"
  end

  test "should handle errors gracefully" do
    # Create a middleware that will cause an error
    error_app = ->(env) { raise StandardError.new("Test error") }
    error_middleware = MetricsMiddleware.new(error_app)
    
    env = Rack::MockRequest.env_for('/test')
    
    # Should not raise an error, should fall back to calling the app
    assert_raises(StandardError) do
      error_middleware.call(env)
    end
  end

  test "should normalize paths with IDs" do
    env = Rack::MockRequest.env_for('/users/123/edit')
    
    @middleware.call(env)
    
    # Should normalize the path
    request_metrics = Metric.where(name: 'http.request.duration')
    assert request_metrics.any? { |m| m.tags['endpoint']&.include?(':id') },
           "Should normalize paths with IDs"
  end

  test "should extract controller and action when available" do
    env = Rack::MockRequest.env_for('/test')
    env['action_dispatch.request.path_parameters'] = { controller: 'users', action: 'show' }
    
    @middleware.call(env)
    
    # Should use controller#action format
    request_metrics = Metric.where(name: 'http.request.duration')
    assert request_metrics.any? { |m| m.tags['endpoint'] == 'users#show' },
           "Should extract controller#action when available"
  end
end