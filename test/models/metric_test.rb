require "test_helper"

class MetricTest < ActiveSupport::TestCase
  def setup
    @metric = Metric.new(
      name: "test.metric",
      value: 42.5,
      timestamp: Time.current
    )
  end

  test "should be valid with required attributes" do
    assert @metric.valid?
  end

  test "should require name" do
    @metric.name = nil
    assert_not @metric.valid?
    assert_includes @metric.errors[:name], "can't be blank"
  end

  test "should require value" do
    @metric.value = nil
    assert_not @metric.valid?
    assert_includes @metric.errors[:value], "can't be blank"
  end

  test "should require timestamp" do
    @metric.timestamp = nil
    assert_not @metric.valid?
    assert_includes @metric.errors[:timestamp], "can't be blank"
  end

  test "should validate value is numeric" do
    @metric.value = "not a number"
    assert_not @metric.valid?
    assert_includes @metric.errors[:value], "is not a number"
  end

  test "should validate aggregation_period inclusion" do
    @metric.aggregation_period = "invalid"
    assert_not @metric.valid?
    assert_includes @metric.errors[:aggregation_period], "is not included in the list"
  end

  test "should allow valid aggregation_periods" do
    %w[raw minute hour day].each do |period|
      @metric.aggregation_period = period
      assert @metric.valid?, "#{period} should be valid"
    end
  end

  test "should allow nil aggregation_period" do
    @metric.aggregation_period = nil
    assert @metric.valid?
  end

  test "should scope by name" do
    metric1 = Metric.create!(name: "cpu.usage", value: 50, timestamp: Time.current)
    metric2 = Metric.create!(name: "memory.usage", value: 75, timestamp: Time.current)
    
    cpu_metrics = Metric.by_name("cpu.usage")
    assert_includes cpu_metrics, metric1
    assert_not_includes cpu_metrics, metric2
  end

  test "should scope by time range" do
    now = Time.current
    old_metric = Metric.create!(name: "test", value: 1, timestamp: 2.hours.ago)
    new_metric = Metric.create!(name: "test", value: 2, timestamp: now)
    
    recent_metrics = Metric.time_range(1.hour.ago, 1.hour.from_now)
    assert_includes recent_metrics, new_metric
    assert_not_includes recent_metrics, old_metric
  end

  test "should get latest value for metric" do
    Metric.create!(name: "test.latest", value: 10, timestamp: 2.hours.ago)
    Metric.create!(name: "test.latest", value: 20, timestamp: 1.hour.ago)
    latest_metric = Metric.create!(name: "test.latest", value: 30, timestamp: Time.current)
    
    assert_equal 30, Metric.latest_value("test.latest")
  end

  test "should handle tags" do
    @metric.tags = { "environment" => "production", "service" => "api" }
    @metric.save!
    
    assert_equal "production", @metric.tag("environment")
    assert_equal "production", @metric.tag(:environment)
    assert_nil @metric.tag("nonexistent")
  end

  test "should add and remove tags" do
    @metric.add_tag("new_key", "new_value")
    assert_equal "new_value", @metric.tag("new_key")
    
    @metric.remove_tag("new_key")
    assert_nil @metric.tag("new_key")
  end

  test "should format values appropriately" do
    time_metric = Metric.new(name: "response.time", value: 123.456)
    assert_equal "123.46ms", time_metric.formatted_value
    
    cpu_metric = Metric.new(name: "cpu.usage", value: 75.123)
    assert_equal "75.1%", cpu_metric.formatted_value
    
    count_metric = Metric.new(name: "request.count", value: 42.7)
    assert_equal "42", count_metric.formatted_value
  end
end