require "test_helper"

class MetricsCollectorTest < ActiveSupport::TestCase
  def setup
    # Clear any existing metrics
    Metric.delete_all
  end

  test "should record request time metric" do
    assert_difference 'Metric.count', 1 do
      MetricsCollector.record_request_time(150.5, "/api/users", { method: "GET" })
    end
    
    metric = Metric.last
    assert_equal "http.request.duration", metric.name
    assert_equal 150.5, metric.value
    assert_equal "/api/users", metric.tag("endpoint")
    assert_equal "GET", metric.tag("method")
  end

  test "should record resource usage metrics" do
    assert_difference 'Metric.count', 2 do
      MetricsCollector.record_resource_usage(75.5, 60.2, { server: "web-01" })
    end
    
    cpu_metric = Metric.find_by(name: "system.cpu.usage")
    memory_metric = Metric.find_by(name: "system.memory.usage")
    
    assert_equal 75.5, cpu_metric.value
    assert_equal 60.2, memory_metric.value
    assert_equal "web-01", cpu_metric.tag("server")
    assert_equal "web-01", memory_metric.tag("server")
  end

  test "should record database query metrics" do
    assert_difference 'Metric.count', 1 do
      MetricsCollector.record_database_query(25.3, "SELECT", { table: "users" })
    end
    
    metric = Metric.last
    assert_equal "database.query.duration", metric.name
    assert_equal 25.3, metric.value
    assert_equal "SELECT", metric.tag("query_type")
    assert_equal "users", metric.tag("table")
  end

  test "should record custom metrics" do
    assert_difference 'Metric.count', 1 do
      MetricsCollector.record_custom_metric("user.login", 1, { user_id: 123 })
    end
    
    metric = Metric.last
    assert_equal "app.user.login", metric.name
    assert_equal 1, metric.value
    assert_equal 123, metric.tag("user_id")
  end

  test "should record AWS metrics" do
    assert_difference 'Metric.count', 1 do
      MetricsCollector.record_aws_metric("s3", "GetObject", 45.2, true, { bucket: "test-bucket" })
    end
    
    metric = Metric.last
    assert_equal "aws.api.duration", metric.name
    assert_equal 45.2, metric.value
    assert_equal "s3", metric.tag("service")
    assert_equal "GetObject", metric.tag("operation")
    assert_equal true, metric.tag("success")
    assert_equal "test-bucket", metric.tag("bucket")
  end

  test "should record batch metrics" do
    metrics_data = [
      { name: "test.metric1", value: 10 },
      { name: "test.metric2", value: 20, tags: { env: "prod" } },
      { name: "test.metric3", value: 30, timestamp: 1.hour.ago }
    ]
    
    assert_difference 'Metric.count', 3 do
      MetricsCollector.record_batch(metrics_data)
    end
    
    assert Metric.exists?(name: "test.metric1", value: 10)
    assert Metric.exists?(name: "test.metric2", value: 20)
    assert Metric.exists?(name: "test.metric3", value: 30)
    
    metric2 = Metric.find_by(name: "test.metric2")
    assert_equal "prod", metric2.tag("env")
  end

  test "should handle empty batch gracefully" do
    assert_no_difference 'Metric.count' do
      MetricsCollector.record_batch([])
      MetricsCollector.record_batch(nil)
    end
  end

  test "should collect system metrics" do
    assert_difference 'Metric.count', 2 do
      result = MetricsCollector.collect_system_metrics
      
      assert result.is_a?(Hash)
      assert result.key?(:cpu)
      assert result.key?(:memory)
      assert result.key?(:disk)
    end
    
    assert Metric.exists?(name: "system.cpu.usage")
    assert Metric.exists?(name: "system.memory.usage")
  end

  test "should cleanup old metrics" do
    # Create old metrics
    old_metric = Metric.create!(
      name: "old.metric",
      value: 1,
      timestamp: 35.days.ago
    )
    
    # Create recent metric
    recent_metric = Metric.create!(
      name: "recent.metric",
      value: 2,
      timestamp: 1.day.ago
    )
    
    deleted_count = MetricsCollector.cleanup_old_metrics(30)
    
    assert_equal 1, deleted_count
    assert_not Metric.exists?(old_metric.id)
    assert Metric.exists?(recent_metric.id)
  end

  test "should handle errors gracefully" do
    # Test with invalid data that would cause an error
    assert_no_difference 'Metric.count' do
      # This should not raise an error, just log it
      MetricsCollector.record_request_time(nil, nil)
    end
  end
end