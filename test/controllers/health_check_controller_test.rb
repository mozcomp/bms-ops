require "test_helper"

class HealthCheckControllerTest < ActionDispatch::IntegrationTest
  private

  def assert_response_in(expected_codes)
    assert_includes expected_codes, response.status, 
      "Expected response to be one of #{expected_codes}, but was #{response.status}"
  end
  test "GET /health returns basic health status" do
    get health_check_path
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["status"].present?
    assert json_response["timestamp"].present?
    assert json_response["version"].present?
    assert json_response["environment"].present?
    assert_not json_response.key?("checks")
  end

  test "GET /health/detailed returns comprehensive health information" do
    get detailed_health_check_path
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["status"].present?
    assert json_response["timestamp"].present?
    assert json_response["version"].present?
    assert json_response["environment"].present?
    assert json_response["checks"].present?
    assert json_response["summary"].present?
    
    # Check that all expected checks are present
    checks = json_response["checks"]
    assert checks.key?("database")
    assert checks.key?("disk_space")
    assert checks.key?("external_services")
    
    # Check summary structure
    summary = json_response["summary"]
    assert summary["total_checks"].present?
    assert summary["healthy_checks"].present?
    assert summary["unhealthy_checks"].present?
    assert summary["unknown_checks"].present?
  end

  test "health check endpoints are accessible without authentication" do
    # These should work without any session or authentication
    get health_check_path
    assert_response :success
    
    get detailed_health_check_path
    assert_response :success
  end

  test "returns appropriate status codes based on health" do
    # Test with actual service - the status will depend on real system state
    get health_check_path
    assert_response_in [200, 503] # Either healthy/unknown (200) or unhealthy (503)
    
    json_response = JSON.parse(response.body)
    assert_includes %w[healthy unhealthy unknown], json_response["status"]
  end
end