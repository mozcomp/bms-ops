require "test_helper"

class ServicePropertiesTest < ActiveSupport::TestCase
  include PropertyTestHelper
  # Feature: infrastructure-management, Property 10: Service JSON field initialization
  # Validates: Requirements 3.1, 4.1
  test "service JSON fields initialize to empty objects when created with only name and image" do
    100.times do
      # Generate random valid service data with only required fields
      name = generate_service_name
      image = generate_image_name
      
      # Create service with only name and image (no JSON fields provided)
      service = Service.create!(
        name: name,
        image: image
      )
      
      # Verify service was persisted
      assert service.persisted?, "Service should be persisted to database"
      assert_not_nil service.id, "Service should have an ID"
      
      # Verify all JSON fields are initialized as empty hashes
      assert_not_nil service.environment, "Environment should not be nil"
      assert service.environment.is_a?(Hash), "Environment should be a Hash"
      assert_equal({}, service.environment, "Environment should be an empty hash")
      
      assert_not_nil service.service_definition, "Service definition should not be nil"
      assert service.service_definition.is_a?(Hash), "Service definition should be a Hash"
      assert_equal({}, service.service_definition, "Service definition should be an empty hash")
      
      assert_not_nil service.task_definitions, "Task definitions should not be nil"
      assert service.task_definitions.is_a?(Hash), "Task definitions should be a Hash"
      assert_equal({}, service.task_definitions, "Task definitions should be an empty hash")
      
      # Clean up
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 11: Full image reference computation
  # Validates: Requirements 3.3
  test "full image reference is computed correctly from registry, image, and version" do
    100.times do
      # Generate random service data with registry, image, and version
      name = generate_service_name
      registry = generate_registry
      image = generate_image_name
      version = generate_version
      
      # Create service with all image components
      service = Service.create!(
        name: name,
        image: image,
        registry: registry,
        version: version
      )
      
      # Verify full_image is computed correctly
      expected_full_image = "#{registry}/#{image}:#{version}"
      assert_equal expected_full_image, service.full_image, "Full image should be registry/image:version"
      
      # Verify format contains all components
      assert service.full_image.include?(registry), "Full image should contain registry"
      assert service.full_image.include?(image), "Full image should contain image name"
      assert service.full_image.include?(version), "Full image should contain version"
      
      # Clean up
      service.destroy!
    end
  end
  
  test "full image defaults to latest when version is not provided" do
    100.times do
      # Generate random service data without version
      name = generate_service_name
      registry = generate_registry
      image = generate_image_name
      
      # Create service without version
      service = Service.create!(
        name: name,
        image: image,
        registry: registry
      )
      
      # Verify full_image uses 'latest' as default version
      expected_full_image = "#{registry}/#{image}:latest"
      assert_equal expected_full_image, service.full_image, "Full image should default to latest version"
      assert service.full_image.end_with?(":latest"), "Full image should end with :latest"
      
      # Clean up
      service.destroy!
    end
  end
  
  test "full image works without registry" do
    100.times do
      # Generate random service data without registry
      name = generate_service_name
      image = generate_image_name
      version = generate_version
      
      # Create service without registry
      service = Service.create!(
        name: name,
        image: image,
        version: version
      )
      
      # Verify full_image works without registry
      expected_full_image = "#{image}:#{version}"
      assert_equal expected_full_image, service.full_image, "Full image should be image:version without registry"
      assert_not service.full_image.include?("/"), "Full image should not contain / when registry is absent"
      
      # Clean up
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 12: JSON parsing error handling
  # Validates: Requirements 3.4, 6.3
  test "JSON parsing errors default fields to empty objects without raising exceptions" do
    100.times do
      # Generate random service data
      name = generate_service_name
      image = generate_image_name
      
      # Create service
      service = Service.create!(
        name: name,
        image: image
      )
      
      # Test environment_json= with invalid JSON
      invalid_json = generate_invalid_json
      service.environment_json = invalid_json
      
      # Verify it defaults to empty hash without raising exception
      assert_equal({}, service.environment, "Environment should default to empty hash on invalid JSON")
      
      # Test service_definition_json= with invalid JSON
      service.service_definition_json = invalid_json
      
      # Verify it defaults to empty hash without raising exception
      assert_equal({}, service.service_definition, "Service definition should default to empty hash on invalid JSON")
      
      # Test task_definitions_json= with invalid JSON
      service.task_definitions_json = invalid_json
      
      # Verify it defaults to empty hash without raising exception
      assert_equal({}, service.task_definitions, "Task definitions should default to empty hash on invalid JSON")
      
      # Verify service can still be saved after invalid JSON
      assert service.save, "Service should be saveable after invalid JSON input"
      
      # Clean up
      service.destroy!
    end
  end
  
  test "JSON parsing handles empty strings gracefully" do
    100.times do
      # Generate random service data
      name = generate_service_name
      image = generate_image_name
      
      # Create service
      service = Service.create!(
        name: name,
        image: image
      )
      
      # Test with empty string
      service.environment_json = ""
      assert_equal({}, service.environment, "Environment should default to empty hash on empty string")
      
      service.service_definition_json = ""
      assert_equal({}, service.service_definition, "Service definition should default to empty hash on empty string")
      
      service.task_definitions_json = ""
      assert_equal({}, service.task_definitions, "Task definitions should default to empty hash on empty string")
      
      # Clean up
      service.destroy!
    end
  end
  
  test "JSON parsing handles nil values gracefully" do
    100.times do
      # Generate random service data
      name = generate_service_name
      image = generate_image_name
      
      # Create service
      service = Service.create!(
        name: name,
        image: image
      )
      
      # Test with nil
      service.environment_json = nil
      assert_equal({}, service.environment, "Environment should default to empty hash on nil")
      
      service.service_definition_json = nil
      assert_equal({}, service.service_definition, "Service definition should default to empty hash on nil")
      
      service.task_definitions_json = nil
      assert_equal({}, service.task_definitions, "Task definitions should default to empty hash on nil")
      
      # Clean up
      service.destroy!
    end
  end
end
