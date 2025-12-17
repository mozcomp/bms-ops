require "test_helper"

class HealthCheckServiceTest < ActiveSupport::TestCase
  def setup
    @service = HealthCheckService.new
  end

  test "check_system_health returns overall status" do
    result = @service.check_system_health
    
    assert_includes %w[healthy unhealthy unknown], result[:status]
    assert result[:timestamp].present?
    assert result[:checks].present?
    assert result[:checks].key?(:database)
    assert result[:checks].key?(:disk_space)
    assert result[:checks].key?(:external_services)
  end

  test "check_database returns healthy status for working database" do
    result = @service.check_database
    
    assert_equal 'healthy', result[:status]
    assert result[:response_time_ms].present?
    assert_equal 'Database connection successful', result[:message]
    assert result[:details][:adapter].present?
    assert result[:details][:database].present?
  end

  test "check_disk_space returns status based on usage" do
    result = @service.check_disk_space
    
    assert_includes %w[healthy unhealthy unknown], result[:status]
    assert result[:response_time_ms].present?
    assert result[:message].include?('Disk usage:')
    assert result[:details][:used_percentage].present?
  end

  test "check_external_services handles AWS connectivity" do
    result = @service.check_external_services
    
    assert_includes %w[healthy unhealthy unknown], result[:status]
    assert result[:response_time_ms].present?
    assert result[:message].present?
  end

  test "stores health check results in database" do
    initial_count = HealthCheck.count
    
    @service.check_system_health
    
    assert HealthCheck.count > initial_count
    
    # Check that all three checks were stored
    recent_checks = HealthCheck.where('checked_at > ?', 1.minute.ago)
    check_names = recent_checks.pluck(:name)
    
    assert_includes check_names, 'database'
    assert_includes check_names, 'disk_space'
    assert_includes check_names, 'external_services'
  end

  test "class method delegates to instance" do
    result = HealthCheckService.check_system_health
    
    assert result.present?
    assert result[:status].present?
    assert result[:checks].present?
  end
end