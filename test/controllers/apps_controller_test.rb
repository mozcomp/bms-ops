require "test_helper"

class AppsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app = apps(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  # Index action tests
  test "should get index" do
    get apps_url
    assert_response :success
    assert_not_nil assigns(:apps)
  end

  test "index should order apps by created_at descending" do
    # Create apps with different timestamps
    app1 = App.create!(name: "Test App 1", repository: "https://github.com/owner/repo1")
    sleep(0.01)
    app2 = App.create!(name: "Test App 2", repository: "https://github.com/owner/repo2")
    sleep(0.01)
    app3 = App.create!(name: "Test App 3", repository: "https://github.com/owner/repo3")
    
    get apps_url
    assert_response :success
    
    apps = assigns(:apps).to_a
    assert apps.index(app3) < apps.index(app2)
    assert apps.index(app2) < apps.index(app1)
  end

  # Show action tests
  test "should show app" do
    get app_url(@app)
    assert_response :success
  end

  # New action tests
  test "should get new" do
    get new_app_url
    assert_response :success
  end

  # Create action tests
  test "should create app with valid data" do
    assert_difference("App.count") do
      post apps_url, params: {
        app: {
          name: "New App",
          repository: "https://github.com/owner/newrepo"
        }
      }
    end

    assert_redirected_to app_url(App.last)
    follow_redirect!
    assert_match /App was successfully created/, response.body
  end

  test "should create app with SSH repository URL" do
    assert_difference("App.count") do
      post apps_url, params: {
        app: {
          name: "SSH App",
          repository: "git@github.com:owner/repo.git"
        }
      }
    end

    assert_redirected_to app_url(App.last)
  end

  test "should not create app with missing required fields" do
    assert_no_difference("App.count") do
      post apps_url, params: {
        app: {
          name: "",
          repository: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create app with duplicate name" do
    assert_no_difference("App.count") do
      post apps_url, params: {
        app: {
          name: @app.name,
          repository: "https://github.com/owner/different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create app with invalid repository URL" do
    assert_no_difference("App.count") do
      post apps_url, params: {
        app: {
          name: "Invalid Repo App",
          repository: "not a valid url"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # Edit action tests
  test "should get edit" do
    get edit_app_url(@app)
    assert_response :success
  end

  # Update action tests
  test "should update app with valid data" do
    patch app_url(@app), params: {
      app: {
        name: "Updated App Name",
        repository: "https://github.com/newowner/newrepo"
      }
    }

    assert_redirected_to app_url(@app)
    follow_redirect!
    assert_match /App was successfully updated/, response.body
    
    @app.reload
    assert_equal "Updated App Name", @app.name
  end

  test "should not update app with invalid data" do
    original_name = @app.name
    
    patch app_url(@app), params: {
      app: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    
    @app.reload
    assert_equal original_name, @app.name
  end

  test "should not update app with invalid repository" do
    original_repo = @app.repository
    
    patch app_url(@app), params: {
      app: {
        repository: "invalid url"
      }
    }

    assert_response :unprocessable_entity
    
    @app.reload
    assert_equal original_repo, @app.repository
  end

  # Destroy action tests
  test "should destroy app" do
    assert_difference("App.count", -1) do
      delete app_url(@app)
    end

    assert_redirected_to apps_url
    follow_redirect!
    assert_match /App was successfully deleted/, response.body
  end

  # Flash message tests
  test "create shows success flash message" do
    post apps_url, params: {
      app: {
        name: "Flash Test App",
        repository: "https://github.com/owner/flashtest"
      }
    }

    follow_redirect!
    assert_match /App was successfully created/, response.body
  end

  test "update shows success flash message" do
    patch app_url(@app), params: {
      app: {
        name: "Updated"
      }
    }

    follow_redirect!
    assert_match /App was successfully updated/, response.body
  end

  test "destroy shows success flash message" do
    delete app_url(@app)
    follow_redirect!
    assert_match /App was successfully deleted/, response.body
  end
end
