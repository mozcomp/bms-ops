require "test_helper"

class InstancePropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 21: Instance creation with associations
  # Validates: Requirements 9.1
  test "instance creation with associations persists with all associations intact" do
    100.times do
      # Create associated records
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      environment = generate_environment
      
      # Create instance with associations
      instance = Instance.create!(
        tenant: tenant,
        app: app,
        service: service,
        environment: environment
      )
      
      # Verify instance was persisted
      assert instance.persisted?, "Instance should be persisted to database"
      assert_not_nil instance.id, "Instance should have an ID"
      
      # Verify all associations are intact
      assert_equal tenant.id, instance.tenant_id, "Tenant association should be preserved"
      assert_equal app.id, instance.app_id, "App association should be preserved"
      assert_equal service.id, instance.service_id, "Service association should be preserved"
      
      # Verify we can access associated records
      assert_equal tenant, instance.tenant, "Should be able to access tenant"
      assert_equal app, instance.app, "Should be able to access app"
      assert_equal service, instance.service, "Should be able to access service"
      
      # Clean up
      instance.destroy!
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 22: Environment validation
  # Validates: Requirements 9.2
  test "environment field only accepts production, staging, or development" do
    100.times do
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      
      # Test valid environments
      valid_env = Rantly { choose("production", "staging", "development") }
      instance = Instance.new(
        tenant: tenant,
        app: app,
        service: service,
        environment: valid_env
      )
      
      assert instance.valid?, "Instance with valid environment (#{valid_env}) should be valid"
      
      # Test invalid environments
      invalid_env = Rantly { 
        choose("prod", "stage", "dev", "test", "qa", "uat", "Production", "STAGING", "", "invalid", "123")
      }
      
      instance_invalid = Instance.new(
        tenant: tenant,
        app: app,
        service: service,
        environment: invalid_env
      )
      
      assert_not instance_invalid.valid?, "Instance with invalid environment (#{invalid_env}) should be invalid"
      assert instance_invalid.errors[:environment].any?, "Should have error on environment field"
      
      # Clean up
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 23: Instance computed fields
  # Validates: Requirements 9.3
  test "instance view representation displays all required fields" do
    100.times do
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      environment = generate_environment
      
      instance = Instance.create!(
        tenant: tenant,
        app: app,
        service: service,
        environment: environment
      )
      
      # Verify all required fields are present
      assert_not_nil instance.tenant, "Tenant should be present"
      assert_not_nil instance.app, "App should be present"
      assert_not_nil instance.service, "Service should be present"
      assert_not_nil instance.environment, "Environment should be present"
      assert_not_nil instance.virtual_host, "Virtual host should be present"
      
      # Verify computed fields
      assert_not_nil instance.environment_label, "Environment label should be present"
      assert_equal environment.capitalize, instance.environment_label, "Environment label should be capitalized"
      
      assert_not_nil instance.full_url, "Full URL should be present"
      assert instance.full_url.start_with?("https://"), "Full URL should start with https://"
      assert_equal "https://#{instance.virtual_host}", instance.full_url, "Full URL should be computed from virtual_host"
      
      # Clean up
      instance.destroy!
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 24: Instance querying by tenant
  # Validates: Requirements 9.4
  test "querying instances by tenant returns all and only instances for that tenant" do
    100.times do
      # Create a tenant with multiple instances
      tenant = create_random_tenant
      other_tenant = create_random_tenant
      
      # Create random number of instances for the tenant
      instance_count = Rantly { range(1, 5) }
      instances = []
      
      instance_count.times do
        app = create_random_app
        service = create_random_service
        env = generate_environment
        
        instance = Instance.create!(
          tenant: tenant,
          app: app,
          service: service,
          environment: env
        )
        instances << instance
      end
      
      # Create some instances for other tenant
      other_count = Rantly { range(1, 3) }
      other_instances = []
      
      other_count.times do
        app = create_random_app
        service = create_random_service
        env = generate_environment
        
        other_instance = Instance.create!(
          tenant: other_tenant,
          app: app,
          service: service,
          environment: env
        )
        other_instances << other_instance
      end
      
      # Query instances by tenant
      tenant_instances = Instance.where(tenant: tenant)
      
      # Verify count matches
      assert_equal instance_count, tenant_instances.count, "Should return correct number of instances for tenant"
      
      # Verify all returned instances belong to the tenant
      tenant_instances.each do |instance|
        assert_equal tenant.id, instance.tenant_id, "All instances should belong to the queried tenant"
      end
      
      # Verify no instances from other tenant are included
      tenant_instance_ids = tenant_instances.pluck(:id)
      other_instances.each do |other_instance|
        assert_not_includes tenant_instance_ids, other_instance.id, "Should not include instances from other tenants"
      end
      
      # Clean up
      instances.each { |i| i.destroy! }
      other_instances.each { |i| i.destroy! }
      tenant.destroy!
      other_tenant.destroy!
    end
  end

  # Feature: infrastructure-management, Property 25: Instance querying by environment
  # Validates: Requirements 9.5
  test "querying instances by environment returns all and only instances for that environment" do
    100.times do
      # Pick a target environment
      target_env = Rantly { choose("production", "staging", "development") }
      other_envs = ["production", "staging", "development"] - [target_env]
      
      # Create instances with target environment
      target_count = Rantly { range(1, 5) }
      target_instances = []
      
      target_count.times do
        tenant = create_random_tenant
        app = create_random_app
        service = create_random_service
        
        instance = Instance.create!(
          tenant: tenant,
          app: app,
          service: service,
          environment: target_env
        )
        target_instances << instance
      end
      
      # Create instances with other environments
      other_count = Rantly { range(1, 3) }
      other_instances = []
      
      other_count.times do
        tenant = create_random_tenant
        app = create_random_app
        service = create_random_service
        other_env = Rantly { choose(*other_envs) }
        
        instance = Instance.create!(
          tenant: tenant,
          app: app,
          service: service,
          environment: other_env
        )
        other_instances << instance
      end
      
      # Query instances by environment
      env_instances = Instance.where(environment: target_env)
      
      # Verify all returned instances have the target environment
      env_instances.each do |instance|
        assert_equal target_env, instance.environment, "All instances should have the queried environment"
      end
      
      # Verify no instances from other environments are included
      env_instance_ids = env_instances.pluck(:id)
      other_instances.each do |other_instance|
        assert_not_includes env_instance_ids, other_instance.id, "Should not include instances from other environments"
      end
      
      # Clean up
      target_instances.each { |i| i.destroy! }
      other_instances.each { |i| i.destroy! }
    end
  end

  # Feature: infrastructure-management, Property 26: Instance deletion preserves associations
  # Validates: Requirements 9.6
  test "deleting instance removes only instance record while preserving associations" do
    100.times do
      # Create instance with associations
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      
      instance = Instance.create!(
        tenant: tenant,
        app: app,
        service: service,
        environment: generate_environment
      )
      
      # Store IDs before deletion
      tenant_id = tenant.id
      app_id = app.id
      service_id = service.id
      instance_id = instance.id
      
      # Delete the instance
      instance.destroy!
      
      # Verify instance is deleted
      assert_nil Instance.find_by(id: instance_id), "Instance should be deleted"
      
      # Verify associated records still exist
      assert_not_nil Tenant.find_by(id: tenant_id), "Tenant should still exist"
      assert_not_nil App.find_by(id: app_id), "App should still exist"
      assert_not_nil Service.find_by(id: service_id), "Service should still exist"
      
      # Clean up
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 27: Instance uniqueness per tenant-app-environment
  # Validates: Requirements 9.7
  test "duplicate tenant-app-environment combination is rejected" do
    100.times do
      # Create first instance
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      environment = generate_environment
      
      instance1 = Instance.create!(
        tenant: tenant,
        app: app,
        service: service,
        environment: environment
      )
      
      # Attempt to create duplicate with same tenant, app, and environment
      instance2 = Instance.new(
        tenant: tenant,
        app: app,
        service: service,  # Can be different service
        environment: environment
      )
      
      # Verify duplicate is rejected
      assert_not instance2.valid?, "Duplicate tenant-app-environment should be invalid"
      assert instance2.errors[:tenant_id].any?, "Should have error on tenant_id uniqueness"
      
      # Verify different environment is allowed
      other_env = (["production", "staging", "development"] - [environment]).sample
      instance3 = Instance.new(
        tenant: tenant,
        app: app,
        service: service,
        environment: other_env
      )
      
      assert instance3.valid?, "Same tenant-app with different environment should be valid"
      
      # Clean up
      instance1.destroy!
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 28: Instance env_vars JSON round-trip
  # Validates: Requirements 9.8
  test "env_vars JSON round-trip preserves data" do
    100.times do
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      
      # Generate random env_vars
      original_env_vars = generate_instance_env_vars
      
      # Create instance with env_vars
      instance = Instance.create!(
        tenant: tenant,
        app: app,
        service: service,
        environment: generate_environment,
        env_vars: original_env_vars
      )
      
      # Retrieve and verify
      retrieved_env_vars = instance.env_vars
      
      # Verify all keys and values are preserved
      original_env_vars.each do |key, value|
        assert_equal value, retrieved_env_vars[key], "Value for key #{key} should be preserved"
      end
      
      # Verify no extra keys were added
      assert_equal original_env_vars.keys.sort, retrieved_env_vars.keys.sort, "Keys should match exactly"
      
      # Clean up
      instance.destroy!
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 29: Instance env_vars JSON parsing error handling
  # Validates: Requirements 9.9
  test "invalid env_vars JSON defaults to empty object" do
    100.times do
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      
      # Create instance
      instance = Instance.new(
        tenant: tenant,
        app: app,
        service: service,
        environment: generate_environment
      )
      
      # Attempt to set invalid JSON via virtual attribute
      invalid_json = generate_invalid_json
      instance.env_vars_json = invalid_json
      
      # Verify it defaults to empty hash without raising exception
      assert_equal({}, instance.env_vars, "Invalid JSON should default to empty hash")
      
      # Verify instance can still be saved
      assert instance.save, "Instance should be saveable even with invalid JSON input"
      
      # Clean up
      instance.destroy!
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 30: Instance env_vars initialization
  # Validates: Requirements 9.8
  test "instance created without env_vars initializes to empty object" do
    100.times do
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      
      # Create instance without env_vars
      instance = Instance.create!(
        tenant: tenant,
        app: app,
        service: service,
        environment: generate_environment
      )
      
      # Verify env_vars is initialized as empty hash
      assert_not_nil instance.env_vars, "env_vars should not be nil"
      assert instance.env_vars.is_a?(Hash), "env_vars should be a Hash"
      assert_equal({}, instance.env_vars, "env_vars should be empty hash")
      
      # Clean up
      instance.destroy!
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end
end
