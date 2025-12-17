module ApplicationLogging
  extend ActiveSupport::Concern
  
  included do
    # Set up request ID tracking for logging context
    before_action :set_request_context if respond_to?(:before_action)
  end
  
  private
  
  def set_request_context
    Current.request_id = request.request_id if defined?(Current)
  end
  
  # Structured logging methods for controllers
  def log_action(action, details = {})
    context = {
      controller: self.class.name,
      action: action,
      request_id: request&.request_id,
      user_id: Current.user&.id,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    }.merge(details)
    
    LoggingService.info("Controller action: #{action}", context)
  end
  
  def log_error(error, details = {})
    context = {
      controller: self.class.name,
      action: action_name,
      error_class: error.class.name,
      error_message: error.message,
      backtrace: error.backtrace&.first(10),
      request_id: request&.request_id,
      user_id: Current.user&.id
    }.merge(details)
    
    LoggingService.error("Controller error: #{error.message}", context)
  end
  
  def log_performance(operation, duration, details = {})
    context = {
      controller: self.class.name,
      action: action_name,
      operation: operation,
      duration_ms: duration,
      request_id: request&.request_id
    }.merge(details)
    
    LoggingService.info("Performance: #{operation} completed in #{duration}ms", context)
  end
end