require "test_helper"

class TenantTest < ActiveSupport::TestCase
  # Validation tests
  
  test "should require code" do
    tenant = Tenant.new(name: "Test Tenant")
    assert_not tenant.valid?
    assert_includes tenant.errors[:code], "can't be blank"
  end
  
  test "should require name" do
    tenant = Tenant.new(code: "test")
    assert_not tenant.valid?
    assert_includes tenant.errors[:name], "can't be blank"
  end
  
  test "should require unique code" do
    Tenant.create!(code: "unique", name: "First Tenant")
    duplicate = Tenant.new(code: "unique", name: "Second Tenant")
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:code], "has already been taken. Each tenant must have a unique code."
  end
  
  test "should allow different codes" do
    Tenant.create!(code: "first", name: "First Tenant")
    second = Tenant.new(code: "second", name: "Second Tenant")
    
    assert second.valid?
  end
  
  # Configuration initialization tests
  
  test "should initialize configuration as empty hash on create" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    
    assert_not_nil tenant.configuration
    assert_equal({}, tenant.configuration)
  end
  
  test "should initialize configuration on new record" do
    tenant = Tenant.new(code: "test", name: "Test Tenant")
    
    assert_not_nil tenant.configuration
    assert_equal({}, tenant.configuration)
  end
  
  # Virtual attribute getter tests
  
  test "subdomain should default to code when not set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_equal "acme", tenant.subdomain
  end
  
  test "subdomain should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.configuration = { "subdomain" => "custom" }
    
    assert_equal "custom", tenant.subdomain
  end
  
  test "database should default to bms_code_production format" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_equal "bms_acme_production", tenant.database
  end
  
  test "database should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.configuration = { "database" => "custom_db" }
    
    assert_equal "custom_db", tenant.database
  end
  
  test "service_name should return nil when not configured" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_nil tenant.service_name
  end
  
  test "service_name should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.configuration = { "service_name" => "bms-acme-service" }
    
    assert_equal "bms-acme-service", tenant.service_name
  end
  
  test "ses_region should default to ap-southeast-2" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_equal "ap-southeast-2", tenant.ses_region
  end
  
  test "ses_region should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.configuration = { "ses_region" => "us-east-1" }
    
    assert_equal "us-east-1", tenant.ses_region
  end
  
  test "s3_bucket should default to bms-code-production format" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_equal "bms-acme-production", tenant.s3_bucket
  end
  
  test "s3_bucket should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.configuration = { "s3_bucket" => "custom-bucket" }
    
    assert_equal "custom-bucket", tenant.s3_bucket
  end
  
  # Virtual attribute setter tests
  
  test "subdomain setter should update configuration" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.subdomain = "custom"
    
    assert_equal "custom", tenant.configuration["subdomain"]
    assert_equal "custom", tenant.subdomain
  end
  
  test "database setter should update configuration" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.database = "custom_db"
    
    assert_equal "custom_db", tenant.configuration["database"]
    assert_equal "custom_db", tenant.database
  end
  
  test "service_name setter should update configuration" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.service_name = "custom-service"
    
    assert_equal "custom-service", tenant.configuration["service_name"]
    assert_equal "custom-service", tenant.service_name
  end
  
  test "ses_region setter should update configuration" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.ses_region = "eu-west-1"
    
    assert_equal "eu-west-1", tenant.configuration["ses_region"]
    assert_equal "eu-west-1", tenant.ses_region
  end
  
  test "s3_bucket setter should update configuration" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.s3_bucket = "my-bucket"
    
    assert_equal "my-bucket", tenant.configuration["s3_bucket"]
    assert_equal "my-bucket", tenant.s3_bucket
  end
  
  # URL computation tests
  
  test "url should be computed from subdomain" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_equal "https://acme.bmserp.com", tenant.url
  end
  
  test "url should use custom subdomain when configured" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.subdomain = "custom"
    
    assert_equal "https://custom.bmserp.com", tenant.url
  end
  
  test "url should always use https protocol" do
    tenant = Tenant.new(code: "test", name: "Test")
    
    assert tenant.url.start_with?("https://")
  end
  
  test "url should always end with bmserp.com domain" do
    tenant = Tenant.new(code: "test", name: "Test")
    
    assert tenant.url.end_with?(".bmserp.com")
  end
  
  # Edge case tests
  
  test "should handle nil configuration gracefully" do
    tenant = Tenant.new(code: "test", name: "Test")
    tenant.configuration = nil
    
    # Should not raise errors and should return defaults
    assert_equal "test", tenant.subdomain
    assert_equal "bms_test_production", tenant.database
    assert_equal "ap-southeast-2", tenant.ses_region
  end
  
  test "should handle empty configuration" do
    tenant = Tenant.new(code: "test", name: "Test")
    tenant.configuration = {}
    
    assert_equal "test", tenant.subdomain
    assert_equal "bms_test_production", tenant.database
  end
  
  test "should persist configuration changes" do
    tenant = Tenant.create!(code: "test", name: "Test")
    tenant.subdomain = "custom"
    tenant.save!
    
    reloaded = Tenant.find(tenant.id)
    assert_equal "custom", reloaded.subdomain
  end
end
