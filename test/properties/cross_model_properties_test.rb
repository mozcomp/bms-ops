require "test_helper"

class CrossModelPropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 2: Contact details JSON round-trip
  # Validates: Requirements 1.2, 3.2, 4.2
  test "JSON contact details round-trip preserves data for all models" do
    100.times do
      # Test Tenant contact details JSON round-trip
      contact_details = generate_contact_details
      tenant = Tenant.create!(
        code: generate_tenant_code,
        name: generate_tenant_name,
        contact: generate_contact_name,
        contact_details: contact_details
      )
      
      # Retrieve and verify tenant contact details
      retrieved_tenant = Tenant.find(tenant.id)
      assert_equal contact_details.stringify_keys, retrieved_tenant.contact_details.stringify_keys,
        "Tenant contact details should round-trip correctly"
      
      # Test Service environment JSON round-trip
      service_env = generate_service_environment
      service = Service.create!(
        name: generate_service_name,
        image: generate_image_name,
        environment: service_env
      )
      
      # Retrieve and verify service environment
      retrieved_service = Service.find(service.id)
      assert_equal service_env.stringify_keys, retrieved_service.environment.stringify_keys,
        "Service environment should round-trip correctly"
      
      # Test Database connection JSON round-trip
      db_connection = generate_database_connection
      database = Database.create!(
        name: generate_database_name,
        connection: db_connection
      )
      
      # Retrieve and verify database connection
      retrieved_database = Database.find(database.id)
      assert_equal db_connection.stringify_keys, retrieved_database.connection.stringify_keys,
        "Database connection should round-trip correctly"
      
      # Test Instance env_vars JSON round-trip
      env_vars = generate_instance_env_vars
      instance = Instance.create!(
        name: generate_instance_name,
        tenant: tenant,
        app: create_random_app,
        service: service,
        environment: generate_environment,
        env_vars: env_vars
      )
      
      # Retrieve and verify instance env_vars
      retrieved_instance = Instance.find(instance.id)
      assert_equal env_vars.stringify_keys, retrieved_instance.env_vars.stringify_keys,
        "Instance env_vars should round-trip correctly"
      
      # Clean up
      instance.destroy!
      database.destroy!
      service.destroy!
      tenant.destroy!
    end
  end

  # Feature: infrastructure-management, Property 4: Deletion removes records
  # Validates: Requirements 1.4
  test "deletion removes records from database for all models" do
    100.times do
      # Create and delete a Tenant
      tenant = create_random_tenant
      tenant_id = tenant.id
      tenant.destroy!
      
      assert_raises(ActiveRecord::RecordNotFound) do
        Tenant.find(tenant_id)
      end
      assert_nil Tenant.find_by(id: tenant_id), "Deleted tenant should not be findable"
      
      # Create and delete an App
      app = create_random_app
      app_id = app.id
      app.destroy!
      
      assert_raises(ActiveRecord::RecordNotFound) do
        App.find(app_id)
      end
      assert_nil App.find_by(id: app_id), "Deleted app should not be findable"
      
      # Create and delete a Service
      service = create_random_service
      service_id = service.id
      service.destroy!
      
      assert_raises(ActiveRecord::RecordNotFound) do
        Service.find(service_id)
      end
      assert_nil Service.find_by(id: service_id), "Deleted service should not be findable"
      
      # Create and delete a Database
      database = create_random_database
      database_id = database.id
      database.destroy!
      
      assert_raises(ActiveRecord::RecordNotFound) do
        Database.find(database_id)
      end
      assert_nil Database.find_by(id: database_id), "Deleted database should not be findable"
      
      # Create and delete an Instance
      instance = create_random_instance
      instance_id = instance.id
      instance.destroy!
      
      assert_raises(ActiveRecord::RecordNotFound) do
        Instance.find(instance_id)
      end
      assert_nil Instance.find_by(id: instance_id), "Deleted instance should not be findable"
    end
  end

  # Feature: infrastructure-management, Property 5: Uniqueness validation
  # Validates: Requirements 1.5, 2.4, 3.5, 4.5, 6.2
  test "uniqueness validation prevents duplicate records across all models" do
    100.times do
      # Test Tenant code uniqueness
      tenant_code = generate_tenant_code
      tenant1 = Tenant.create!(
        code: tenant_code,
        name: generate_tenant_name
      )
      
      tenant2 = Tenant.new(
        code: tenant_code,
        name: generate_tenant_name
      )
      
      assert_not tenant2.valid?, "Duplicate tenant code should be invalid"
      assert tenant2.errors[:code].any?, "Tenant code should have uniqueness error"
      
      # Test App name uniqueness
      app_name = generate_app_name
      app1 = App.create!(
        name: app_name,
        repository: generate_repository_url
      )
      
      app2 = App.new(
        name: app_name,
        repository: generate_repository_url
      )
      
      assert_not app2.valid?, "Duplicate app name should be invalid"
      assert app2.errors[:name].any?, "App name should have uniqueness error"
      
      # Test Service name uniqueness
      service_name = generate_service_name
      service1 = Service.create!(
        name: service_name,
        image: generate_image_name
      )
      
      service2 = Service.new(
        name: service_name,
        image: generate_image_name
      )
      
      assert_not service2.valid?, "Duplicate service name should be invalid"
      assert service2.errors[:name].any?, "Service name should have uniqueness error"
      
      # Test Database name uniqueness
      database_name = generate_database_name
      database1 = Database.create!(
        name: database_name
      )
      
      database2 = Database.new(
        name: database_name
      )
      
      assert_not database2.valid?, "Duplicate database name should be invalid"
      assert database2.errors[:name].any?, "Database name should have uniqueness error"
      
      # Clean up
      tenant1.destroy!
      app1.destroy!
      service1.destroy!
      database1.destroy!
    end
  end

  # Feature: infrastructure-management, Property 15: Required field validation
  # Validates: Requirements 6.1
  test "required field validation rejects records with missing fields" do
    100.times do
      # Test Tenant required fields
      tenant_without_code = Tenant.new(name: generate_tenant_name)
      assert_not tenant_without_code.valid?, "Tenant without code should be invalid"
      assert tenant_without_code.errors[:code].any?, "Code should have presence error"
      
      tenant_without_name = Tenant.new(code: generate_tenant_code)
      assert_not tenant_without_name.valid?, "Tenant without name should be invalid"
      assert tenant_without_name.errors[:name].any?, "Name should have presence error"
      
      # Test App required fields
      app_without_name = App.new(repository: generate_repository_url)
      assert_not app_without_name.valid?, "App without name should be invalid"
      assert app_without_name.errors[:name].any?, "Name should have presence error"
      
      app_without_repository = App.new(name: generate_app_name)
      assert_not app_without_repository.valid?, "App without repository should be invalid"
      assert app_without_repository.errors[:repository].any?, "Repository should have presence error"
      
      # Test Service required fields
      service_without_name = Service.new(image: generate_image_name)
      assert_not service_without_name.valid?, "Service without name should be invalid"
      assert service_without_name.errors[:name].any?, "Name should have presence error"
      
      service_without_image = Service.new(name: generate_service_name)
      assert_not service_without_image.valid?, "Service without image should be invalid"
      assert service_without_image.errors[:image].any?, "Image should have presence error"
      
      # Test Database required fields
      database_without_name = Database.new
      assert_not database_without_name.valid?, "Database without name should be invalid"
      assert database_without_name.errors[:name].any?, "Name should have presence error"
      
      # Test Instance required fields
      tenant = create_random_tenant
      app = create_random_app
      service = create_random_service
      
      instance_without_tenant = Instance.new(
        app: app,
        service: service,
        environment: generate_environment
      )
      assert_not instance_without_tenant.valid?, "Instance without tenant should be invalid"
      assert instance_without_tenant.errors[:tenant].any?, "Tenant should have presence error"
      
      instance_without_app = Instance.new(
        tenant: tenant,
        service: service,
        environment: generate_environment
      )
      assert_not instance_without_app.valid?, "Instance without app should be invalid"
      assert instance_without_app.errors[:app].any?, "App should have presence error"
      
      instance_without_service = Instance.new(
        tenant: tenant,
        app: app,
        environment: generate_environment
      )
      assert_not instance_without_service.valid?, "Instance without service should be invalid"
      assert instance_without_service.errors[:service].any?, "Service should have presence error"
      
      instance_without_environment = Instance.new(
        tenant: tenant,
        app: app,
        service: service
      )
      assert_not instance_without_environment.valid?, "Instance without environment should be invalid"
      assert instance_without_environment.errors[:environment].any?, "Environment should have presence error"
      
      # Clean up
      tenant.destroy!
      app.destroy!
      service.destroy!
    end
  end

  # Feature: infrastructure-management, Property 16: Update validation preserves state
  # Validates: Requirements 6.5
  test "update validation preserves original state when validation fails" do
    100.times do
      # Test Tenant update validation
      tenant = create_random_tenant
      original_code = tenant.code
      original_name = tenant.name
      
      # Try to update with invalid data (empty code)
      tenant.code = ""
      assert_not tenant.save, "Tenant should not save with invalid code"
      
      # Reload and verify original state is preserved
      tenant.reload
      assert_equal original_code, tenant.code, "Original code should be preserved"
      assert_equal original_name, tenant.name, "Original name should be preserved"
      
      # Test App update validation
      app = create_random_app
      original_name = app.name
      original_repository = app.repository
      
      # Try to update with invalid data (invalid repository)
      app.repository = "not a valid url"
      assert_not app.save, "App should not save with invalid repository"
      
      # Reload and verify original state is preserved
      app.reload
      assert_equal original_name, app.name, "Original name should be preserved"
      assert_equal original_repository, app.repository, "Original repository should be preserved"
      
      # Test Service update validation
      service = create_random_service
      original_name = service.name
      original_image = service.image
      
      # Try to update with invalid data (empty name)
      service.name = ""
      assert_not service.save, "Service should not save with invalid name"
      
      # Reload and verify original state is preserved
      service.reload
      assert_equal original_name, service.name, "Original name should be preserved"
      assert_equal original_image, service.image, "Original image should be preserved"
      
      # Test Database update validation
      database = create_random_database
      original_name = database.name
      
      # Try to update with invalid data (empty name)
      database.name = ""
      assert_not database.save, "Database should not save with invalid name"
      
      # Reload and verify original state is preserved
      database.reload
      assert_equal original_name, database.name, "Original name should be preserved"
      
      # Test Instance update validation
      instance = create_random_instance
      original_environment = instance.environment
      original_virtual_host = instance.virtual_host
      
      # Try to update with invalid data (invalid environment)
      instance.environment = "invalid_env"
      assert_not instance.save, "Instance should not save with invalid environment"
      
      # Reload and verify original state is preserved
      instance.reload
      assert_equal original_environment, instance.environment, "Original environment should be preserved"
      assert_equal original_virtual_host, instance.virtual_host, "Original virtual_host should be preserved"
      
      # Clean up
      instance.destroy!
      database.destroy!
      service.destroy!
      app.destroy!
      tenant.destroy!
    end
  end
end
