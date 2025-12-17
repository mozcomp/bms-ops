require "test_helper"

class HealthCheckTest < ActiveSupport::TestCase
  test "should validate presence of required fields" do
    health_check = HealthCheck.new
    assert_not health_check.valid?
    assert_includes health_check.errors[:name], "can't be blank"
    assert_includes health_check.errors[:status], "can't be blank"
    assert_includes health_check.errors[:checked_at], "can't be blank"
  end

  test "should validate status inclusion" do
    health_check = HealthCheck.new(
      name: "test",
      status: "invalid",
      checked_at: Time.current
    )
    assert_not health_check.valid?
    assert_includes health_check.errors[:status], "is not included in the list"
  end

  test "should accept valid status values" do
    %w[healthy unhealthy unknown].each do |status|
      health_check = HealthCheck.new(
        name: "test",
        status: status,
        checked_at: Time.current
      )
      assert health_check.valid?, "#{status} should be valid"
    end
  end

  test "current scope should return recent health checks" do
    old_check = HealthCheck.create!(
      name: "old_test",
      status: "healthy",
      checked_at: 10.minutes.ago
    )
    
    recent_check = HealthCheck.create!(
      name: "recent_test",
      status: "healthy",
      checked_at: 1.minute.ago
    )

    current_checks = HealthCheck.current
    assert_includes current_checks, recent_check
    assert_not_includes current_checks, old_check
  end

  test "unhealthy scope should return only unhealthy checks" do
    healthy_check = HealthCheck.create!(
      name: "healthy_test",
      status: "healthy",
      checked_at: Time.current
    )
    
    unhealthy_check = HealthCheck.create!(
      name: "unhealthy_test",
      status: "unhealthy",
      checked_at: Time.current
    )

    unhealthy_checks = HealthCheck.unhealthy
    assert_includes unhealthy_checks, unhealthy_check
    assert_not_includes unhealthy_checks, healthy_check
  end

  test "status helper methods should work correctly" do
    healthy_check = HealthCheck.new(status: "healthy")
    unhealthy_check = HealthCheck.new(status: "unhealthy")
    unknown_check = HealthCheck.new(status: "unknown")

    assert healthy_check.healthy?
    assert_not healthy_check.unhealthy?
    assert_not healthy_check.unknown?

    assert_not unhealthy_check.healthy?
    assert unhealthy_check.unhealthy?
    assert_not unhealthy_check.unknown?

    assert_not unknown_check.healthy?
    assert_not unknown_check.unhealthy?
    assert unknown_check.unknown?
  end
end
