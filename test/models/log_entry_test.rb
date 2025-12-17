require "test_helper"

class LogEntryTest < ActiveSupport::TestCase
  test "should create log entry with required attributes" do
    log_entry = LogEntry.create_entry("info", "Test message", { test: true })
    
    assert log_entry.persisted?
    assert_equal "info", log_entry.level
    assert_equal "Test message", log_entry.message
    assert_equal({ "test" => true }, log_entry.context)
    assert_not_nil log_entry.timestamp
  end
  
  test "should validate presence of required fields" do
    log_entry = LogEntry.new
    
    assert_not log_entry.valid?
    assert_includes log_entry.errors[:timestamp], "can't be blank"
    assert_includes log_entry.errors[:level], "can't be blank"
    assert_includes log_entry.errors[:message], "can't be blank"
  end
  
  test "should validate level inclusion" do
    log_entry = LogEntry.new(
      timestamp: Time.current,
      level: "invalid",
      message: "Test message"
    )
    
    assert_not log_entry.valid?
    assert_includes log_entry.errors[:level], "is not included in the list"
  end
  
  test "should accept valid log levels" do
    %w[debug info warn error fatal].each do |level|
      log_entry = LogEntry.create_entry(level, "Test message")
      assert log_entry.persisted?, "Failed to create log entry with level: #{level}"
    end
  end
  
  test "should generate structured JSON" do
    log_entry = LogEntry.create_entry("info", "Test message", { test: true })
    json_output = log_entry.to_structured_json
    parsed = JSON.parse(json_output)
    
    assert_equal "info", parsed["level"]
    assert_equal "Test message", parsed["message"]
    assert_equal({ "test" => true }, parsed["context"])
    assert_not_nil parsed["timestamp"]
  end
  
  test "should scope by level" do
    LogEntry.create_entry("info", "Info message")
    LogEntry.create_entry("error", "Error message")
    
    info_entries = LogEntry.by_level("info")
    error_entries = LogEntry.by_level("error")
    
    assert info_entries.all? { |entry| entry.level == "info" }
    assert error_entries.all? { |entry| entry.level == "error" }
  end
  
  test "should scope recent entries" do
    old_entry = LogEntry.create!(
      timestamp: 2.days.ago,
      level: "info",
      message: "Old message"
    )
    recent_entry = LogEntry.create_entry("info", "Recent message")
    
    recent_entries = LogEntry.recent(24)
    
    assert_includes recent_entries, recent_entry
    assert_not_includes recent_entries, old_entry
  end
end