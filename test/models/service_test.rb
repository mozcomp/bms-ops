require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  # Validation tests
  test "should require name" do
    service = Service.new(image: "test-image")
    assert_not service.valid?
    assert_includes service.errors[:name], "can't be blank"
  end
  
  test "should require image" do
    service = Service.new(name: "Test Service")
    assert_not service.valid?
    assert_includes service.errors[:image], "can't be blank"
  end
  
  test "should require unique name" do
    Service.create!(name: "Unique Service", image: "test-image")
    duplicate = Service.new(name: "Unique Service", image: "another-image")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken. Each service must have a unique name."
  end
  
  test "should be valid with name and image" do
    service = Service.new(name: "Valid Service", image: "valid-image")
    assert service.valid?
  end
  
  # JSON field initialization tests
  test "should initialize JSON fields to empty hashes on create" do
    service = Service.create!(name: "Test Service", image: "test-image")
    assert_equal({}, service.environment)
    assert_equal({}, service.service_definition)
    assert_equal({}, service.task_definitions)
  end
  
  test "should preserve JSON fields when provided" do
    env = { "DATABASE_URL" => "mysql2://localhost/test" }
    service = Service.create!(
      name: "Test Service",
      image: "test-image",
      environment: env
    )
    assert_equal env, service.environment
  end
  
  # full_image computation tests
  test "full_image with registry, image, and version" do
    service = Service.new(
      name: "Test",
      registry: "docker.io",
      image: "myapp",
      version: "1.0.0"
    )
    assert_equal "docker.io/myapp:1.0.0", service.full_image
  end
  
  test "full_image defaults to latest when version is nil" do
    service = Service.new(
      name: "Test",
      registry: "docker.io",
      image: "myapp"
    )
    assert_equal "docker.io/myapp:latest", service.full_image
  end
  
  test "full_image without registry" do
    service = Service.new(
      name: "Test",
      image: "myapp",
      version: "2.0.0"
    )
    assert_equal "myapp:2.0.0", service.full_image
  end
  
  test "full_image without registry defaults to latest" do
    service = Service.new(
      name: "Test",
      image: "myapp"
    )
    assert_equal "myapp:latest", service.full_image
  end
  
  test "full_image returns not configured when image is blank" do
    service = Service.new(name: "Test")
    assert_equal "Not configured", service.full_image
  end
  
  # JSON parsing error handling tests
  test "environment_json= handles invalid JSON" do
    service = Service.create!(name: "Test", image: "test-image")
    service.environment_json = "{invalid json}"
    assert_equal({}, service.environment)
  end
  
  test "service_definition_json= handles invalid JSON" do
    service = Service.create!(name: "Test", image: "test-image")
    service.service_definition_json = "not json at all"
    assert_equal({}, service.service_definition)
  end
  
  test "task_definitions_json= handles invalid JSON" do
    service = Service.create!(name: "Test", image: "test-image")
    service.task_definitions_json = "{'single': 'quotes'}"
    assert_equal({}, service.task_definitions)
  end
  
  test "environment_json= handles empty string" do
    service = Service.create!(name: "Test", image: "test-image")
    service.environment_json = ""
    assert_equal({}, service.environment)
  end
  
  test "environment_json= handles nil" do
    service = Service.create!(name: "Test", image: "test-image")
    service.environment_json = nil
    assert_equal({}, service.environment)
  end
  
  test "environment_json= parses valid JSON" do
    service = Service.create!(name: "Test", image: "test-image")
    json_string = '{"DATABASE_URL":"mysql2://localhost/test","RAILS_ENV":"production"}'
    service.environment_json = json_string
    expected = { "DATABASE_URL" => "mysql2://localhost/test", "RAILS_ENV" => "production" }
    assert_equal expected, service.environment
  end
  
  # Virtual attribute getter tests
  test "environment_json returns JSON string" do
    env = { "KEY" => "value" }
    service = Service.create!(name: "Test", image: "test-image", environment: env)
    assert_equal env.to_json, service.environment_json
  end
  
  test "environment_json returns nil when environment is empty" do
    service = Service.create!(name: "Test", image: "test-image")
    assert_nil service.environment_json
  end
  
  # Edge cases
  test "should handle very long image names" do
    long_image = "a" * 255
    service = Service.create!(name: "Test", image: long_image)
    assert_equal "#{long_image}:latest", service.full_image
  end
  
  test "should handle special characters in version" do
    service = Service.new(
      name: "Test",
      image: "myapp",
      version: "1.0.0-beta.1+build.123"
    )
    assert_equal "myapp:1.0.0-beta.1+build.123", service.full_image
  end
  
  test "should handle ECR registry format" do
    service = Service.new(
      name: "Test",
      registry: "123456789012.dkr.ecr.us-east-1.amazonaws.com",
      image: "myapp",
      version: "latest"
    )
    assert_equal "123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest", service.full_image
  end
end
