require "test_helper"
require "ostruct"

class ApplicationLoggingTest < ActiveSupport::TestCase
  class TestController < ActionController::Base
    include ApplicationLogging
    
    attr_accessor :request
    
    def action_name
      "test_action"
    end
    
    def test_log_action
      log_action("test_action", { custom_data: "test" })
    end
    
    def test_log_error
      error = StandardError.new("Test error")
      log_error(error, { additional_context: "test" })
    end
    
    def test_log_performance
      log_performance("test_operation", 150, { operation_type: "test" })
    end
  end
  
  setup do
    @controller = TestController.new
    
    # Mock request object
    @request = OpenStruct.new(
      request_id: "test-request-id-123",
      remote_ip: "127.0.0.1",
      user_agent: "Test Agent"
    )
    @controller.request = @request
    
    # Set up Current.user through a session
    @user = users(:one)
    @session = Session.create!(user: @user, user_agent: "Test Agent", ip_address: "127.0.0.1")
    Current.session = @session
    
    # Set request_id in Current as well
    Current.request_id = "test-request-id-123"
  end
  
  test "should log action with context" do
    initial_count = LogEntry.count
    
    @controller.test_log_action
    
    assert_equal initial_count + 1, LogEntry.count
    
    log_entry = LogEntry.first
    assert_equal "info", log_entry.level
    assert_includes log_entry.message, "Controller action: test_action"
    assert_includes log_entry.context, "controller"
    assert_includes log_entry.context, "action"
    assert_includes log_entry.context, "custom_data"
    assert_equal "test", log_entry.context["custom_data"]
    # User ID should be present since we set Current.session
    assert_equal @user.id, log_entry.context["user_id"]
    assert_equal "test-request-id-123", log_entry.context["request_id"]
  end
  
  test "should log error with context and backtrace" do
    initial_count = LogEntry.count
    
    @controller.test_log_error
    
    assert_equal initial_count + 1, LogEntry.count
    
    log_entry = LogEntry.first
    assert_equal "error", log_entry.level
    assert_includes log_entry.message, "Controller error: Test error"
    assert_includes log_entry.context, "error_class"
    assert_includes log_entry.context, "error_message"
    assert_includes log_entry.context, "backtrace"
    assert_includes log_entry.context, "additional_context"
    assert_equal "StandardError", log_entry.context["error_class"]
    assert_equal "Test error", log_entry.context["error_message"]
    assert_equal "test", log_entry.context["additional_context"]
  end
  
  test "should log performance with timing data" do
    initial_count = LogEntry.count
    
    @controller.test_log_performance
    
    assert_equal initial_count + 1, LogEntry.count
    
    log_entry = LogEntry.first
    assert_equal "info", log_entry.level
    assert_includes log_entry.message, "Performance: test_operation completed in 150ms"
    assert_includes log_entry.context, "operation"
    assert_includes log_entry.context, "duration_ms"
    assert_includes log_entry.context, "operation_type"
    assert_equal "test_operation", log_entry.context["operation"]
    assert_equal 150, log_entry.context["duration_ms"]
    assert_equal "test", log_entry.context["operation_type"]
  end
  
  test "should set request context" do
    # Call the private method directly to test context setting
    @controller.send(:set_request_context)
    
    # Verify Current.request_id is set
    assert_equal "test-request-id-123", Current.request_id
  end
end