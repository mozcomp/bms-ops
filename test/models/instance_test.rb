require "test_helper"

class InstanceTest < ActiveSupport::TestCase
  # Validation tests
  
  test "should require name" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_not instance.valid?
    assert_includes instance.errors[:name], "can't be blank"
  end
  
  test "should require unique name" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    Instance.create!(
      name: "unique-instance",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    duplicate = Instance.new(
      name: "unique-instance",
      tenant: tenant,
      app: app,
      service: service,
      environment: "staging"
    )
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken. Each instance must have a unique name."
  end
  
  test "should allow different names" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    Instance.create!(
      name: "first-instance",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    second = Instance.new(
      name: "second-instance",
      tenant: tenant,
      app: app,
      service: service,
      environment: "staging"
    )
    
    assert second.valid?
  end

  # Association tests
  
  test "should belong to tenant" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-3",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_equal tenant, instance.tenant
    assert_equal tenant.id, instance.tenant_id
  end
  
  test "should belong to app" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-4",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_equal app, instance.app
    assert_equal app.id, instance.app_id
  end
  
  test "should belong to service" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-5",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_equal service, instance.service
    assert_equal service.id, instance.service_id
  end
  
  # Validation tests
  
  test "should require tenant" do
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-4",
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_not instance.valid?
    assert_includes instance.errors[:tenant_id], "can't be blank"
  end
  
  test "should require app" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-5",
      tenant: tenant,
      service: service,
      environment: "production"
    )
    
    assert_not instance.valid?
    assert_includes instance.errors[:app_id], "can't be blank"
  end
  
  test "should require service" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    
    instance = Instance.new(
      name: "test-instance-new-6",
      tenant: tenant,
      app: app,
      environment: "production"
    )
    
    assert_not instance.valid?
    assert_includes instance.errors[:service_id], "can't be blank"
  end
  
  test "should require environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-7",
      tenant: tenant,
      app: app,
      service: service
    )
    
    assert_not instance.valid?
    assert_includes instance.errors[:environment], "can't be blank"
  end
  
  test "should require virtual_host" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-8",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production",
      virtual_host: nil
    )
    
    # This should be valid because virtual_host is auto-generated
    assert instance.valid?
  end
  
  # Environment validation tests
  
  test "should accept production environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-9",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert instance.valid?
  end
  
  test "should accept staging environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-10",
      tenant: tenant,
      app: app,
      service: service,
      environment: "staging"
    )
    
    assert instance.valid?
  end
  
  test "should accept development environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-11",
      tenant: tenant,
      app: app,
      service: service,
      environment: "development"
    )
    
    assert instance.valid?
  end
  
  test "should reject invalid environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-12",
      tenant: tenant,
      app: app,
      service: service,
      environment: "invalid"
    )
    
    assert_not instance.valid?
    assert_includes instance.errors[:environment], "is not included in the list"
  end
  
  test "should reject uppercase environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-13",
      tenant: tenant,
      app: app,
      service: service,
      environment: "Production"
    )
    
    assert_not instance.valid?
  end
  
  # Uniqueness constraint tests
  
  test "should enforce uniqueness of tenant-app-environment combination" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service1 = Service.create!(name: "Test Service 1", image: "test-image-1")
    service2 = Service.create!(name: "Test Service 2", image: "test-image-2")
    
    # Create first instance
    Instance.create!(
      name: "test-instance-6",
      tenant: tenant,
      app: app,
      service: service1,
      environment: "production"
    )
    
    # Attempt to create duplicate
    duplicate = Instance.new(
      name: "test-instance-new-14",
      tenant: tenant,
      app: app,
      service: service2,  # Different service, but same tenant-app-environment
      environment: "production"
    )
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tenant_id], "already has an instance for this app in this environment"
  end
  
  test "should allow same tenant-app with different environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    # Create production instance
    Instance.create!(
      name: "test-instance-7",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    # Create staging instance (should be valid)
    staging_instance = Instance.new(
      name: "test-instance-new-15",
      tenant: tenant,
      app: app,
      service: service,
      environment: "staging"
    )
    
    assert staging_instance.valid?
  end
  
  test "should allow same app-environment with different tenant" do
    tenant1 = Tenant.create!(code: "test1", name: "Test Tenant 1")
    tenant2 = Tenant.create!(code: "test2", name: "Test Tenant 2")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    # Create instance for tenant1
    Instance.create!(
      name: "test-instance-8",
      tenant: tenant1,
      app: app,
      service: service,
      environment: "production"
    )
    
    # Create instance for tenant2 (should be valid)
    instance2 = Instance.new(
      name: "test-instance-new-16",
      tenant: tenant2,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert instance2.valid?
  end
  
  # Computed methods tests
  
  test "environment_label should capitalize environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-9",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_equal "Production", instance.environment_label
  end
  
  test "full_url should return https URL with virtual_host" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-10",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production",
      virtual_host: "test.bmserp.com"
    )
    
    assert_equal "https://test.bmserp.com", instance.full_url
  end
  
  test "full_url should return nil when virtual_host is nil" do
    instance = Instance.new(virtual_host: nil)
    
    assert_nil instance.full_url
  end
  
  # Virtual host generation tests
  
  test "should auto-generate virtual_host for production" do
    tenant = Tenant.create!(code: "acme", name: "Acme Corp")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-11",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_equal "acme.bmserp.com", instance.virtual_host
  end
  
  test "should auto-generate virtual_host for staging with prefix" do
    tenant = Tenant.create!(code: "acme", name: "Acme Corp")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-12",
      tenant: tenant,
      app: app,
      service: service,
      environment: "staging"
    )
    
    assert_equal "staging-acme.bmserp.com", instance.virtual_host
  end
  
  test "should auto-generate virtual_host for development with prefix" do
    tenant = Tenant.create!(code: "acme", name: "Acme Corp")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-13",
      tenant: tenant,
      app: app,
      service: service,
      environment: "development"
    )
    
    assert_equal "development-acme.bmserp.com", instance.virtual_host
  end
  
  test "should use tenant code for virtual host generation" do
    tenant = Tenant.create!(code: "acme", name: "Acme Corp")
    
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-14",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_equal "acme.bmserp.com", instance.virtual_host
  end
  
  test "should not override manually set virtual_host" do
    tenant = Tenant.create!(code: "acme", name: "Acme Corp")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-15",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production",
      virtual_host: "custom.example.com"
    )
    
    assert_equal "custom.example.com", instance.virtual_host
  end
  
  # env_vars JSON tests
  
  test "should initialize env_vars as empty hash" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.create!(
      name: "test-instance-16",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    assert_not_nil instance.env_vars
    assert_equal({}, instance.env_vars)
  end
  
  test "should store and retrieve env_vars" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    env_vars = {
      "DATABASE_URL" => "mysql2://localhost/test",
      "REDIS_URL" => "redis://localhost:6379/0",
      "SECRET_KEY_BASE" => "secret123"
    }
    
    instance = Instance.create!(
      name: "test-instance-17",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production",
      env_vars: env_vars
    )
    
    assert_equal env_vars, instance.env_vars
  end
  
  test "env_vars_json should return JSON string" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    env_vars = { "KEY" => "value" }
    
    instance = Instance.create!(
      name: "test-instance-18",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production",
      env_vars: env_vars
    )
    
    assert_equal env_vars.to_json, instance.env_vars_json
  end
  
  test "env_vars_json= should parse valid JSON" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-17",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    json_string = '{"KEY":"value","ANOTHER":"test"}'
    instance.env_vars_json = json_string
    
    assert_equal({ "KEY" => "value", "ANOTHER" => "test" }, instance.env_vars)
  end
  
  test "env_vars_json= should handle invalid JSON gracefully" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-18",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    instance.env_vars_json = "invalid json"
    
    assert_equal({}, instance.env_vars)
  end
  
  test "env_vars_json= should handle empty string" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance = Instance.new(
      name: "test-instance-new-19",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    instance.env_vars_json = ""
    
    assert_equal({}, instance.env_vars)
  end
  
  # Scopes and querying tests
  
  test "should query instances by tenant" do
    tenant1 = Tenant.create!(code: "test1", name: "Test Tenant 1")
    tenant2 = Tenant.create!(code: "test2", name: "Test Tenant 2")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    instance1 = Instance.create!(
      name: "test-instance-19",
      tenant: tenant1,
      app: app,
      service: service,
      environment: "production"
    )
    
    instance2 = Instance.create!(
      name: "test-instance-20",
      tenant: tenant2,
      app: app,
      service: service,
      environment: "production"
    )
    
    tenant1_instances = Instance.where(tenant: tenant1)
    
    assert_includes tenant1_instances, instance1
    assert_not_includes tenant1_instances, instance2
  end
  
  test "should query instances by environment" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service = Service.create!(name: "Test Service", image: "test-image")
    
    prod_instance = Instance.create!(
      name: "test-instance-21",
      tenant: tenant,
      app: app,
      service: service,
      environment: "production"
    )
    
    staging_instance = Instance.create!(
      name: "test-instance-22",
      tenant: tenant,
      app: app,
      service: service,
      environment: "staging"
    )
    
    prod_instances = Instance.where(environment: "production")
    
    assert_includes prod_instances, prod_instance
    assert_not_includes prod_instances, staging_instance
  end
  
  test "should query instances by service" do
    tenant = Tenant.create!(code: "test", name: "Test Tenant")
    app = App.create!(name: "Test App", repository: "https://github.com/test/repo")
    service1 = Service.create!(name: "Test Service 1", image: "test-image-1")
    service2 = Service.create!(name: "Test Service 2", image: "test-image-2")
    
    instance1 = Instance.create!(
      name: "test-instance-23",
      tenant: tenant,
      app: app,
      service: service1,
      environment: "production"
    )
    
    instance2 = Instance.create!(
      name: "test-instance-24",
      tenant: tenant,
      app: app,
      service: service2,
      environment: "staging"
    )
    
    service1_instances = Instance.where(service: service1)
    
    assert_includes service1_instances, instance1
    assert_not_includes service1_instances, instance2
  end
end
