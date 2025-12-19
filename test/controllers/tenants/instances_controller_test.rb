require "test_helper"

class Tenants::InstancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = tenants(:one)
    @service = services(:one)
    @app = apps(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should create instance with minimal params" do
    assert_difference("Instance.count") do
      post tenant_instances_url(@tenant), params: {
        instance: {
          service_id: @service.id,
          environment: "development"
        }
      }
    end

    instance = Instance.last
    assert_equal @tenant, instance.tenant
    assert_equal @service, instance.service
    assert_equal "development", instance.environment
    assert_not_nil instance.name
    assert_not_nil instance.virtual_host
    
    assert_redirected_to @tenant
  end

  test "should not create instance without required params" do
    assert_no_difference("Instance.count") do
      post tenant_instances_url(@tenant), params: {
        instance: {
          environment: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end
end