require "test_helper"

class LoggingServiceTest < ActiveSupport::TestCase
  test "should create log entry through service" do
    initial_count = LogEntry.count
    
    entry = LoggingService.log_event("info", "Service test message", { service: true })
    
    assert_equal initial_count + 1, LogEntry.count
    assert_not_nil entry
    assert_equal "info", entry.level
    assert_equal "Service test message", entry.message
    assert_includes entry.context, "service"
    assert_equal true, entry.context["service"]
  end
  
  test "should handle logging failures gracefully" do
    # Test that logging failures don't break the application
    # We'll simulate this by testing with invalid data that would cause a validation error
    # but the service should handle it gracefully
    
    # Create a scenario where LogEntry creation might fail
    original_method = LogEntry.method(:create_entry)
    LogEntry.define_singleton_method(:create_entry) do |*args|
      raise StandardError, "Database error"
    end
    
    begin
      # Should not raise an error and should return nil
      entry = LoggingService.log_event("error", "Test message")
      assert_nil entry
    ensure
      # Restore the original method
      LogEntry.define_singleton_method(:create_entry, original_method)
    end
  end
  
  test "should provide convenience methods for different levels" do
    %w[debug info warn error fatal].each do |level|
      entry = LoggingService.send(level, "#{level.capitalize} message")
      assert_not_nil entry
      assert_equal level, entry.level
      assert_equal "#{level.capitalize} message", entry.message
    end
  end
  
  test "should format entry as structured JSON" do
    entry = LogEntry.create_entry("info", "Test message", { test: true })
    json_output = LoggingService.format_entry(entry)
    parsed = JSON.parse(json_output)
    
    assert_equal "info", parsed["level"]
    assert_equal "Test message", parsed["message"]
    assert_equal({ "test" => true }, parsed["context"])
  end
  
  test "should configure database destination" do
    result = LoggingService.configure_destination(:database)
    assert result
  end
  
  test "should raise error for unknown destination" do
    assert_raises ArgumentError do
      LoggingService.configure_destination(:unknown)
    end
  end
end