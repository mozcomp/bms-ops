require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @service = services(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  # Index action tests
  test "should get index" do
    get services_url
    assert_response :success
    assert_not_nil assigns(:services)
  end

  test "index should order services by created_at descending" do
    # Create services with different timestamps
    service1 = Service.create!(name: "Test Service 1", image: "image1")
    sleep(0.01)
    service2 = Service.create!(name: "Test Service 2", image: "image2")
    sleep(0.01)
    service3 = Service.create!(name: "Test Service 3", image: "image3")
    
    get services_url
    assert_response :success
    
    services = assigns(:services).to_a
    assert services.index(service3) < services.index(service2)
    assert services.index(service2) < services.index(service1)
  end

  # Show action tests
  test "should show service" do
    get service_url(@service)
    assert_response :success
  end

  # New action tests
  test "should get new" do
    get new_service_url
    assert_response :success
  end

  # Create action tests
  test "should create service with valid data" do
    assert_difference("Service.count") do
      post services_url, params: {
        service: {
          name: "New Service",
          image: "newimage",
          registry: "docker.io",
          version: "1.0.0"
        }
      }
    end

    assert_redirected_to service_url(Service.last)
    follow_redirect!
    assert_match /Service was successfully created/, response.body
  end

  test "should create service with JSON environment variables" do
    env_json = '{"DATABASE_URL": "mysql2://localhost/db", "REDIS_URL": "redis://localhost"}'
    
    assert_difference("Service.count") do
      post services_url, params: {
        service: {
          name: "Service with Env",
          image: "envimage",
          environment_json: env_json
        }
      }
    end

    assert_redirected_to service_url(Service.last)
    
    service = Service.last
    assert_equal "mysql2://localhost/db", service.environment["DATABASE_URL"]
  end

  test "should not create service with missing required fields" do
    assert_no_difference("Service.count") do
      post services_url, params: {
        service: {
          name: "",
          image: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create service with duplicate name" do
    assert_no_difference("Service.count") do
      post services_url, params: {
        service: {
          name: @service.name,
          image: "differentimage"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle invalid JSON gracefully" do
    assert_difference("Service.count") do
      post services_url, params: {
        service: {
          name: "Service with Invalid JSON",
          image: "invalidjsonimage",
          environment_json: "{invalid json}"
        }
      }
    end

    # Should create with empty environment
    service = Service.last
    assert_equal({}, service.environment)
  end

  # Edit action tests
  test "should get edit" do
    get edit_service_url(@service)
    assert_response :success
  end

  # Update action tests
  test "should update service with valid data" do
    patch service_url(@service), params: {
      service: {
        name: "Updated Service",
        version: "2.0.0"
      }
    }

    assert_redirected_to service_url(@service)
    follow_redirect!
    assert_match /Service was successfully updated/, response.body
    
    @service.reload
    assert_equal "Updated Service", @service.name
    assert_equal "2.0.0", @service.version
  end

  test "should not update service with invalid data" do
    original_name = @service.name
    
    patch service_url(@service), params: {
      service: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    
    @service.reload
    assert_equal original_name, @service.name
  end

  # Destroy action tests
  test "should destroy service" do
    assert_difference("Service.count", -1) do
      delete service_url(@service)
    end

    assert_redirected_to services_url
    follow_redirect!
    assert_match /Service was successfully deleted/, response.body
  end

  # Flash message tests
  test "create shows success flash message" do
    post services_url, params: {
      service: {
        name: "Flash Test Service",
        image: "flashimage"
      }
    }

    follow_redirect!
    assert_match /Service was successfully created/, response.body
  end

  test "update shows success flash message" do
    patch service_url(@service), params: {
      service: {
        name: "Updated"
      }
    }

    follow_redirect!
    assert_match /Service was successfully updated/, response.body
  end

  test "destroy shows success flash message" do
    delete service_url(@service)
    follow_redirect!
    assert_match /Service was successfully deleted/, response.body
  end
end
