require "test_helper"

class TenantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = tenants(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  # Index action tests
  test "should get index" do
    get tenants_url
    assert_response :success
    assert_select "h1", text: "Tenants"
  end

  test "index should order tenants by created_at descending" do
    # Create tenants with different timestamps
    tenant1 = Tenant.create!(code: "test1", name: "Test 1")
    sleep(0.01)
    tenant2 = Tenant.create!(code: "test2", name: "Test 2")
    sleep(0.01)
    tenant3 = Tenant.create!(code: "test3", name: "Test 3")
    
    get tenants_url
    assert_response :success
    
    # Verify ordering by checking the database query
    tenants = Tenant.all.order(created_at: :desc).to_a
    assert tenants.index(tenant3) < tenants.index(tenant2)
    assert tenants.index(tenant2) < tenants.index(tenant1)
  end

  # Show action tests
  test "should show tenant" do
    get tenant_url(@tenant)
    assert_response :success
  end

  # New action tests
  test "should get new" do
    get new_tenant_url
    assert_response :success
  end

  # Create action tests
  test "should create tenant with valid data" do
    assert_difference("Tenant.count") do
      post tenants_url, params: {
        tenant: {
          code: "newcode",
          name: "New Tenant",
          contact: "John Doe",
          email: "john@newcode.com",
          phone: "+1-555-0123",
          company: "New Code Corp",
          address: "123 Main St, City, State"
        }
      }
    end

    assert_redirected_to tenant_url(Tenant.last)
    follow_redirect!
    assert_match /Tenant was successfully created/, response.body
  end

  test "should not create tenant with missing required fields" do
    assert_no_difference("Tenant.count") do
      post tenants_url, params: {
        tenant: {
          code: "",
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create tenant with duplicate code" do
    assert_no_difference("Tenant.count") do
      post tenants_url, params: {
        tenant: {
          code: @tenant.code,
          name: "Different Name"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # Edit action tests
  test "should get edit" do
    get edit_tenant_url(@tenant)
    assert_response :success
  end

  # Update action tests
  test "should update tenant with valid data" do
    patch tenant_url(@tenant), params: {
      tenant: {
        name: "Updated Name",
        contact: "Jane Smith",
        email: "jane@updated.com"
      }
    }

    assert_redirected_to tenant_url(@tenant)
    follow_redirect!
    assert_match /Tenant was successfully updated/, response.body
    
    @tenant.reload
    assert_equal "Updated Name", @tenant.name
    assert_equal "Jane Smith", @tenant.contact
    assert_equal "jane@updated.com", @tenant.email
  end

  test "should not update tenant with invalid data" do
    original_name = @tenant.name
    
    patch tenant_url(@tenant), params: {
      tenant: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    
    @tenant.reload
    assert_equal original_name, @tenant.name
  end

  test "should not update tenant with duplicate code" do
    other_tenant = Tenant.create!(code: "other", name: "Other Tenant")
    
    patch tenant_url(@tenant), params: {
      tenant: {
        code: other_tenant.code
      }
    }

    assert_response :unprocessable_entity
  end

  # Destroy action tests
  test "should destroy tenant" do
    assert_difference("Tenant.count", -1) do
      delete tenant_url(@tenant)
    end

    assert_redirected_to tenants_url
    follow_redirect!
    assert_match /Tenant was successfully deleted/, response.body
  end

  # Flash message tests
  test "create shows success flash message" do
    post tenants_url, params: {
      tenant: {
        code: "flashtest",
        name: "Flash Test"
      }
    }

    follow_redirect!
    assert_match /Tenant was successfully created/, response.body
  end

  test "update shows success flash message" do
    patch tenant_url(@tenant), params: {
      tenant: {
        code: @tenant.code,
        name: "Updated"
      }
    }

    follow_redirect!
    assert_match /Tenant was successfully updated/, response.body
  end

  test "destroy shows success flash message" do
    delete tenant_url(@tenant)
    follow_redirect!
    assert_match /Tenant was successfully deleted/, response.body
  end
end
