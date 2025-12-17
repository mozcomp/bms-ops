require "test_helper"

class TenantPropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 1: Tenant creation with defaults
  # Validates: Requirements 1.1
  test "tenant creation with defaults persists with initialized contact_details" do
    100.times do
      # Generate random valid tenant data
      code = generate_tenant_code
      name = generate_tenant_name
      
      # Create tenant without explicit contact details
      tenant = Tenant.create!(
        code: code,
        name: name
      )
      
      # Verify tenant was persisted
      assert tenant.persisted?, "Tenant should be persisted to database"
      assert_not_nil tenant.id, "Tenant should have an ID"
      
      # Verify contact_details is initialized as empty hash
      assert_not_nil tenant.contact_details, "Contact details should not be nil"
      assert tenant.contact_details.is_a?(Hash), "Contact details should be a Hash"
      
      # Verify we can access virtual attributes (should return nil when not set)
      assert_nil tenant.email, "Email should be nil when not set"
      assert_nil tenant.phone, "Phone should be nil when not set"
      assert_nil tenant.address, "Address should be nil when not set"
      assert_nil tenant.company, "Company should be nil when not set"
      
      # Verify URL is computed from code
      expected_url = "https://#{code}.bmserp.com"
      assert_equal expected_url, tenant.url, "URL should be computed from code"
      
      # Clean up
      tenant.destroy!
    end
  end

  # Feature: infrastructure-management, Property 3: Tenant computed fields presence
  # Validates: Requirements 1.3
  test "tenant computed fields are present and correctly formatted" do
    100.times do
      # Generate random tenant with full contact details
      code = generate_tenant_code
      name = generate_tenant_name
      contact = generate_contact_name
      contact_details = generate_contact_details
      
      # Create tenant with contact information
      tenant = Tenant.create!(
        code: code,
        name: name,
        contact: contact,
        contact_details: contact_details
      )
      
      # Verify all required fields are present
      assert_not_nil tenant.code, "Code should be present"
      assert_not_nil tenant.name, "Name should be present"
      assert_not_nil tenant.contact, "Contact should be present"
      assert_not_nil tenant.url, "URL should be present"
      
      # Verify contact details virtual attributes work
      if contact_details["email"]
        assert_equal contact_details["email"], tenant.email, "Email should match contact details"
      end
      if contact_details["phone"]
        assert_equal contact_details["phone"], tenant.phone, "Phone should match contact details"
      end
      if contact_details["address"]
        assert_equal contact_details["address"], tenant.address, "Address should match contact details"
      end
      if contact_details["company"]
        assert_equal contact_details["company"], tenant.company, "Company should match contact details"
      end
      
      # Verify URL is correctly computed from code
      expected_url = "https://#{code}.bmserp.com"
      assert_equal expected_url, tenant.url, "URL should be computed from code"
      
      # Verify URL format
      assert tenant.url.start_with?("https://"), "URL should start with https://"
      assert tenant.url.end_with?(".bmserp.com"), "URL should end with .bmserp.com"
      
      # Clean up
      tenant.destroy!
    end
  end
end
