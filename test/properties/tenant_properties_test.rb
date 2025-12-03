require "test_helper"

class TenantPropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 1: Tenant creation with defaults
  # Validates: Requirements 1.1
  test "tenant creation with defaults persists with initialized configuration" do
    100.times do
      # Generate random valid tenant data
      code = generate_tenant_code
      name = generate_tenant_name
      
      # Create tenant without explicit configuration
      tenant = Tenant.create!(
        code: code,
        name: name
      )
      
      # Verify tenant was persisted
      assert tenant.persisted?, "Tenant should be persisted to database"
      assert_not_nil tenant.id, "Tenant should have an ID"
      
      # Verify configuration is initialized as empty hash
      assert_not_nil tenant.configuration, "Configuration should not be nil"
      assert tenant.configuration.is_a?(Hash), "Configuration should be a Hash"
      
      # Verify we can access virtual attributes with defaults
      assert_equal code, tenant.subdomain, "Subdomain should default to code"
      assert_equal "bms_#{code}_production", tenant.database, "Database should have default format"
      assert_equal "ap-southeast-2", tenant.ses_region, "SES region should have default value"
      assert_equal "bms-#{code}-production", tenant.s3_bucket, "S3 bucket should have default format"
      
      # Clean up
      tenant.destroy!
    end
  end

  # Feature: infrastructure-management, Property 3: Tenant computed fields presence
  # Validates: Requirements 1.3
  test "tenant computed fields are present and correctly formatted" do
    100.times do
      # Generate random tenant with full configuration
      code = generate_tenant_code
      name = generate_tenant_name
      config = generate_tenant_configuration
      
      # Create tenant with configuration
      tenant = Tenant.create!(
        code: code,
        name: name,
        configuration: config
      )
      
      # Verify all required computed fields are present
      assert_not_nil tenant.code, "Code should be present"
      assert_not_nil tenant.name, "Name should be present"
      assert_not_nil tenant.subdomain, "Subdomain should be present"
      assert_not_nil tenant.database, "Database name should be present"
      assert_not_nil tenant.service_name, "Service name should be present"
      assert_not_nil tenant.ses_region, "SES region should be present"
      assert_not_nil tenant.s3_bucket, "S3 bucket should be present"
      assert_not_nil tenant.url, "URL should be present"
      
      # Verify URL is correctly computed from subdomain
      expected_url = "https://#{tenant.subdomain}.bmserp.com"
      assert_equal expected_url, tenant.url, "URL should be computed from subdomain"
      
      # Verify URL format
      assert tenant.url.start_with?("https://"), "URL should start with https://"
      assert tenant.url.end_with?(".bmserp.com"), "URL should end with .bmserp.com"
      
      # Clean up
      tenant.destroy!
    end
  end
end
