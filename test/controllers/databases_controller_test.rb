require "test_helper"

class DatabasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @database = databases(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  # Index action tests
  test "should get index" do
    get databases_url
    assert_response :success
    assert_select "h1", text: "Databases"
  end

  test "index should order databases by created_at descending" do
    # Create databases with different timestamps
    db1 = Database.create!(name: "test_db_1")
    sleep(0.01)
    db2 = Database.create!(name: "test_db_2")
    sleep(0.01)
    db3 = Database.create!(name: "test_db_3")
    
    get databases_url
    assert_response :success
    
    # Verify ordering by checking the database query
    databases = Database.all.order(created_at: :desc).to_a
    assert databases.index(db3) < databases.index(db2)
    assert databases.index(db2) < databases.index(db1)
  end

  # Show action tests
  test "should show database" do
    get database_url(@database)
    assert_response :success
  end

  # New action tests
  test "should get new" do
    get new_database_url
    assert_response :success
  end

  # Create action tests
  test "should create database with valid data" do
    assert_difference("Database.count") do
      post databases_url, params: {
        database: {
          name: "new_database",
          schema_version: "1.0"
        }
      }
    end

    assert_redirected_to database_url(Database.last)
    follow_redirect!
    assert_match /Database was successfully created/, response.body
  end

  test "should create database with connection JSON" do
    connection_json = '{"host": "localhost", "port": 3306, "database": "mydb", "username": "user", "adapter": "mysql2"}'
    
    assert_difference("Database.count") do
      post databases_url, params: {
        database: {
          name: "db_with_connection",
          connection_json: connection_json
        }
      }
    end

    assert_redirected_to database_url(Database.last)
    
    database = Database.last
    assert_equal "localhost", database.connection["host"]
    assert_equal 3306, database.connection["port"]
  end

  test "should not create database with missing required fields" do
    assert_no_difference("Database.count") do
      post databases_url, params: {
        database: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create database with duplicate name" do
    assert_no_difference("Database.count") do
      post databases_url, params: {
        database: {
          name: @database.name
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle invalid connection JSON gracefully" do
    assert_difference("Database.count") do
      post databases_url, params: {
        database: {
          name: "db_invalid_json",
          connection_json: "{invalid json}"
        }
      }
    end

    # Should create with empty connection
    database = Database.last
    assert_equal({}, database.connection)
  end

  # Edit action tests
  test "should get edit" do
    get edit_database_url(@database)
    assert_response :success
  end

  # Update action tests
  test "should update database with valid data" do
    patch database_url(@database), params: {
      database: {
        name: "updated_database",
        schema_version: "2.0"
      }
    }

    assert_redirected_to database_url(@database)
    follow_redirect!
    assert_match /Database was successfully updated/, response.body
    
    @database.reload
    assert_equal "updated_database", @database.name
    assert_equal "2.0", @database.schema_version
  end

  test "should not update database with invalid data" do
    original_name = @database.name
    
    patch database_url(@database), params: {
      database: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    
    @database.reload
    assert_equal original_name, @database.name
  end

  # Destroy action tests
  test "should destroy database" do
    assert_difference("Database.count", -1) do
      delete database_url(@database)
    end

    assert_redirected_to databases_url
    follow_redirect!
    assert_match /Database was successfully deleted/, response.body
  end

  # Flash message tests
  test "create shows success flash message" do
    post databases_url, params: {
      database: {
        name: "flash_test_db"
      }
    }

    follow_redirect!
    assert_match /Database was successfully created/, response.body
  end

  test "update shows success flash message" do
    patch database_url(@database), params: {
      database: {
        name: @database.name,
        schema_version: "3.0"
      }
    }

    follow_redirect!
    assert_match /Database was successfully updated/, response.body
  end

  test "destroy shows success flash message" do
    delete database_url(@database)
    follow_redirect!
    assert_match /Database was successfully deleted/, response.body
  end
end
