class LoggingService
  class << self
    # Log an event with structured data
    def log_event(level, message, context = {})
      # Add request context if available
      enhanced_context = context.dup
      if defined?(Current) && Current.respond_to?(:request_id)
        enhanced_context[:request_id] = Current.request_id
      end
      if defined?(Current) && Current.respond_to?(:user)
        enhanced_context[:user_id] = Current.user&.id
      end
      
      # Create database log entry
      log_entry = LogEntry.create_entry(level, message, enhanced_context)
      
      # Also log to Rails logger with structured format
      log_to_rails_logger(level, message, enhanced_context)
      
      log_entry
    rescue => e
      # Ensure logging failures don't break the application
      Rails.logger.error "Failed to create log entry: #{e.message}"
      # Still log to Rails logger as fallback
      log_to_rails_logger(level, message, context)
      nil
    end
    
    # Configure logging destination (for future extensibility)
    def configure_destination(type, options = {})
      case type
      when :database
        # Database logging is always enabled
        true
      when :file
        # File logging configuration would go here
        configure_file_logging(options)
      when :external
        # External service logging configuration would go here
        configure_external_logging(options)
      else
        raise ArgumentError, "Unknown logging destination: #{type}"
      end
    end
    
    # Format log entry as structured JSON
    def format_entry(entry)
      if entry.is_a?(LogEntry)
        entry.to_structured_json
      else
        {
          timestamp: Time.current.iso8601,
          level: entry[:level],
          message: entry[:message],
          context: entry[:context] || {}
        }.to_json
      end
    end
    
    # Convenience methods for different log levels
    def debug(message, context = {})
      log_event(:debug, message, context)
    end
    
    def info(message, context = {})
      log_event(:info, message, context)
    end
    
    def warn(message, context = {})
      log_event(:warn, message, context)
    end
    
    def error(message, context = {})
      log_event(:error, message, context)
    end
    
    def fatal(message, context = {})
      log_event(:fatal, message, context)
    end
    
    private
    
    def log_to_rails_logger(level, message, context)
      structured_data = {
        message: message,
        context: context,
        timestamp: Time.current.iso8601
      }
      
      Rails.logger.send(level, structured_data.to_json)
    end
    
    def configure_file_logging(options)
      # File logging configuration implementation
      # This would be implemented based on specific requirements
      true
    end
    
    def configure_external_logging(options)
      # External logging service configuration implementation
      # This would be implemented based on specific requirements
      true
    end
  end
end