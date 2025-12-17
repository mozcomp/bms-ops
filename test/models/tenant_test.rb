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
  
  # Contact details initialization tests
  
  test "should initialize contact_details as empty hash on create" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    
    assert_not_nil tenant.contact_details
    assert_equal({}, tenant.contact_details)
  end
  
  test "should initialize contact_details on new record" do
    tenant = Tenant.new(code: "test", name: "Test Tenant")
    
    assert_not_nil tenant.contact_details
    assert_equal({}, tenant.contact_details)
  end
  
  # Contact field tests
  
  test "should store and retrieve contact string" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.contact = "John Doe"
    
    assert_equal "John Doe", tenant.contact
  end
  
  test "should persist contact field" do
    tenant = Tenant.create!(code: "test", name: "Test", contact: "Jane Smith")
    
    reloaded = Tenant.find(tenant.id)
    assert_equal "Jane Smith", reloaded.contact
  end
  
  # Virtual attribute getter tests for contact_details
  
  test "email should return nil when not set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_nil tenant.email
  end
  
  test "email should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.contact_details = { "email" => "contact@acme.com" }
    
    assert_equal "contact@acme.com", tenant.email
  end
  
  test "phone should return nil when not set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_nil tenant.phone
  end
  
  test "phone should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.contact_details = { "phone" => "+1-555-0123" }
    
    assert_equal "+1-555-0123", tenant.phone
  end
  
  test "address should return nil when not set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_nil tenant.address
  end
  
  test "address should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.contact_details = { "address" => "123 Main St, City, State" }
    
    assert_equal "123 Main St, City, State", tenant.address
  end
  
  test "company should return nil when not set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_nil tenant.company
  end
  
  test "company should return configured value when set" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.contact_details = { "company" => "Acme Corporation" }
    
    assert_equal "Acme Corporation", tenant.company
  end
  
  # Virtual attribute setter tests for contact_details
  
  test "email setter should update contact_details" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.email = "test@acme.com"
    
    assert_equal "test@acme.com", tenant.contact_details["email"]
    assert_equal "test@acme.com", tenant.email
  end
  
  test "phone setter should update contact_details" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.phone = "+1-555-9999"
    
    assert_equal "+1-555-9999", tenant.contact_details["phone"]
    assert_equal "+1-555-9999", tenant.phone
  end
  
  test "address setter should update contact_details" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.address = "456 Oak Ave, Town, State"
    
    assert_equal "456 Oak Ave, Town, State", tenant.contact_details["address"]
    assert_equal "456 Oak Ave, Town, State", tenant.address
  end
  
  test "company setter should update contact_details" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    tenant.company = "Acme Industries"
    
    assert_equal "Acme Industries", tenant.contact_details["company"]
    assert_equal "Acme Industries", tenant.company
  end
  
  # URL computation tests
  
  test "url should be computed from code" do
    tenant = Tenant.new(code: "acme", name: "Acme Corp")
    
    assert_equal "https://acme.bmserp.com", tenant.url
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
  
  test "should handle nil contact_details gracefully" do
    tenant = Tenant.new(code: "test", name: "Test")
    tenant.contact_details = nil
    
    # Should not raise errors and should return nil for all contact fields
    assert_nil tenant.email
    assert_nil tenant.phone
    assert_nil tenant.address
    assert_nil tenant.company
  end
  
  test "should handle empty contact_details" do
    tenant = Tenant.new(code: "test", name: "Test")
    tenant.contact_details = {}
    
    assert_nil tenant.email
    assert_nil tenant.phone
    assert_nil tenant.address
    assert_nil tenant.company
  end
  
  test "should persist contact_details changes" do
    tenant = Tenant.create!(code: "test", name: "Test")
    tenant.email = "test@example.com"
    tenant.phone = "+1-555-0123"
    tenant.save!
    
    reloaded = Tenant.find(tenant.id)
    assert_equal "test@example.com", reloaded.email
    assert_equal "+1-555-0123", reloaded.phone
  end
  
  test "should handle mixed string and symbol keys in contact_details" do
    tenant = Tenant.new(code: "test", name: "Test")
    tenant.contact_details = { :email => "symbol@test.com", "phone" => "string-phone" }
    
    assert_equal "symbol@test.com", tenant.email
    assert_equal "string-phone", tenant.phone
  end
end
