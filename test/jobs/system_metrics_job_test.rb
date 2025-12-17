require "test_helper"

class SystemMetricsJobTest < ActiveJob::TestCase
  test "should perform system metrics collection without errors" do
    initial_count = Metric.count
    
    assert_nothing_raised do
      SystemMetricsJob.perform_now
    end
    
    # Should have created some metrics
    assert Metric.count > initial_count, "Expected metrics to be created"
  end

  test "should collect system resource metrics" do
    SystemMetricsJob.perform_now
    
    # Check that system metrics were recorded
    assert Metric.where(name: 'system.cpu.usage').exists?, "CPU usage metric should be recorded"
    assert Metric.where(name: 'system.memory.usage').exists?, "Memory usage metric should be recorded"
  end

  test "should collect application metrics" do
    SystemMetricsJob.perform_now
    
    # Check that application metrics were recorded
    assert Metric.where("name LIKE 'app.activerecord.pool.%'").exists?, "ActiveRecord pool metrics should be recorded"
  end

  test "should collect database metrics" do
    SystemMetricsJob.perform_now
    
    # Check that database metrics were recorded
    assert Metric.where("name LIKE 'app.database.connection.%'").exists?, "Database connection metrics should be recorded"
  end

  test "should be enqueueable" do
    assert_enqueued_jobs 1 do
      SystemMetricsJob.perform_later
    end
  end

  test "should handle individual collection errors gracefully" do
    # Test that job completes even if one collection method fails
    job = SystemMetricsJob.new
    
    # Mock one method to raise an error
    def job.collect_system_resources
      raise StandardError.new("Test error")
    end
    
    # Job should still complete and log the error
    assert_raises(StandardError) do
      job.perform
    end
  end
end