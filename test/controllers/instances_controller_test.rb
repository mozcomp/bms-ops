require "test_helper"

class InstancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
    
    @instance = instances(:one)
    @tenant = tenants(:one)
    @app = apps(:one)
    @service = services(:one)
  end

  test "should get index" do
    get instances_url
    assert_response :success
    assert_select "h1", "Instances"
  end

  test "should filter index by tenant" do
    get instances_url, params: { tenant_id: @tenant.id }
    assert_response :success
  end

  test "should filter index by environment" do
    get instances_url, params: { environment: "production" }
    assert_response :success
  end

  test "should filter index by service" do
    get instances_url, params: { service_id: @service.id }
    assert_response :success
  end

  test "should get new" do
    get new_instance_url
    assert_response :success
    assert_select "h1", "New Instance"
  end

  test "should create instance" do
    assert_difference("Instance.count") do
      post instances_url, params: {
        instance: {
          tenant_id: @tenant.id,
          app_id: @app.id,
          service_id: @service.id,
          environment: "development",
          virtual_host: "dev-test.bmserp.com"
        }
      }
    end

    assert_redirected_to instance_url(Instance.last)
    assert_equal "Instance was successfully created.", flash[:notice]
  end

  test "should create instance with env_vars JSON" do
    env_vars = { "DATABASE_URL" => "mysql2://test", "REDIS_URL" => "redis://test" }

    assert_difference("Instance.count") do
      post instances_url, params: {
        instance: {
          tenant_id: @tenant.id,
          app_id: @app.id,
          service_id: @service.id,
          environment: "development",
          env_vars_json: env_vars.to_json
        }
      }
    end

    instance = Instance.last
    assert_equal env_vars, instance.env_vars
  end

  test "should handle invalid env_vars JSON gracefully" do
    assert_difference("Instance.count") do
      post instances_url, params: {
        instance: {
          tenant_id: @tenant.id,
          app_id: @app.id,
          service_id: @service.id,
          environment: "development",
          env_vars_json: "invalid json {"
        }
      }
    end

    instance = Instance.last
    assert_equal({}, instance.env_vars)
  end

  test "should not create instance with missing required fields" do
    assert_no_difference("Instance.count") do
      post instances_url, params: {
        instance: {
          tenant_id: nil,
          app_id: @app.id,
          service_id: @service.id,
          environment: "production"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create instance with invalid environment" do
    assert_no_difference("Instance.count") do
      post instances_url, params: {
        instance: {
          tenant_id: @tenant.id,
          app_id: @app.id,
          service_id: @service.id,
          environment: "invalid_env"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create duplicate instance for same tenant-app-environment" do
    # First instance already exists in fixtures
    assert_no_difference("Instance.count") do
      post instances_url, params: {
        instance: {
          tenant_id: @instance.tenant_id,
          app_id: @instance.app_id,
          service_id: @instance.service_id,
          environment: @instance.environment
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show instance" do
    get instance_url(@instance)
    assert_response :success
    assert_select "h1", /#{@instance.tenant.name}/
  end

  test "should get edit" do
    get edit_instance_url(@instance)
    assert_response :success
    assert_select "h1", "Edit Instance"
  end

  test "should update instance" do
    patch instance_url(@instance), params: {
      instance: {
        virtual_host: "updated.bmserp.com"
      }
    }

    assert_redirected_to instance_url(@instance)
    assert_equal "Instance was successfully updated.", flash[:notice]

    @instance.reload
    assert_equal "updated.bmserp.com", @instance.virtual_host
  end

  test "should update instance env_vars" do
    new_env_vars = { "NEW_VAR" => "new_value", "ANOTHER_VAR" => "another_value" }

    patch instance_url(@instance), params: {
      instance: {
        env_vars_json: new_env_vars.to_json
      }
    }

    assert_redirected_to instance_url(@instance)

    @instance.reload
    assert_equal new_env_vars, @instance.env_vars
  end

  test "should not update instance with invalid data" do
    original_environment = @instance.environment

    patch instance_url(@instance), params: {
      instance: {
        environment: "invalid_env"
      }
    }

    assert_response :unprocessable_entity

    @instance.reload
    assert_equal original_environment, @instance.environment
  end

  test "should destroy instance" do
    assert_difference("Instance.count", -1) do
      delete instance_url(@instance)
    end

    assert_redirected_to instances_url
    assert_equal "Instance was successfully deleted.", flash[:notice]
  end

  test "should preserve tenant, app, and service after instance deletion" do
    tenant_id = @instance.tenant_id
    app_id = @instance.app_id
    service_id = @instance.service_id

    delete instance_url(@instance)

    assert Tenant.exists?(tenant_id)
    assert App.exists?(app_id)
    assert Service.exists?(service_id)
  end
end
