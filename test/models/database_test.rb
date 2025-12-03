require "test_helper"

class DatabaseTest < ActiveSupport::TestCase
  # Validation tests
  test "should require name" do
    database = Database.new(connection: {})
    assert_not database.valid?
    assert_includes database.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    Database.create!(name: "test_db", connection: {})
    duplicate = Database.new(name: "test_db", connection: {})
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  # Connection JSON parsing tests
  test "should parse valid connection JSON" do
    database = Database.new(name: "test_db")
    database.connection_json = '{"host":"localhost","port":3306,"database":"mydb","username":"user","adapter":"mysql2"}'
    
    assert_equal "localhost", database.host
    assert_equal 3306, database.port
    assert_equal "mydb", database.database_name
    assert_equal "user", database.username
    assert_equal "mysql2", database.adapter
  end

  test "should handle invalid JSON gracefully" do
    database = Database.new(name: "test_db")
    database.connection_json = "{invalid json}"
    
    assert_equal({}, database.connection)
    assert_equal "localhost", database.host
    assert_equal 3306, database.port
  end

  test "should handle empty JSON string" do
    database = Database.new(name: "test_db")
    database.connection_json = ""
    
    assert_equal({}, database.connection)
  end

  test "should handle nil JSON string" do
    database = Database.new(name: "test_db")
    database.connection_json = nil
    
    assert_equal({}, database.connection)
  end

  # Connection string formatting tests
  test "should format connection string with all fields" do
    database = Database.create!(
      name: "test_db",
      connection: {
        host: "db.example.com",
        port: 5432,
        database: "production_db",
        username: "admin",
        adapter: "postgresql"
      }
    )
    
    expected = "postgresql://admin@db.example.com:5432/production_db"
    assert_equal expected, database.connection_string
  end

  test "should format connection string with mysql2 adapter" do
    database = Database.create!(
      name: "test_db",
      connection: {
        host: "localhost",
        port: 3306,
        database: "myapp_production",
        username: "root",
        adapter: "mysql2"
      }
    )
    
    expected = "mysql2://root@localhost:3306/myapp_production"
    assert_equal expected, database.connection_string
  end

  test "should show 'Not configured' when connection is empty" do
    database = Database.create!(name: "test_db", connection: {})
    assert_equal "Not configured", database.connection_string
  end

  test "should show 'Not configured' when connection is nil" do
    database = Database.create!(name: "test_db")
    assert_equal "Not configured", database.connection_string
  end

  # Default value handling tests
  test "should default host to localhost when missing" do
    database = Database.create!(
      name: "test_db",
      connection: { port: 3306, database: "mydb" }
    )
    
    assert_equal "localhost", database.host
  end

  test "should default port to 3306 when missing" do
    database = Database.create!(
      name: "test_db",
      connection: { host: "db.example.com", database: "mydb" }
    )
    
    assert_equal 3306, database.port
  end

  test "should default database_name to name when missing" do
    database = Database.create!(
      name: "test_db",
      connection: { host: "localhost", port: 3306 }
    )
    
    assert_equal "test_db", database.database_name
  end

  test "should default adapter to mysql2 when missing" do
    database = Database.create!(
      name: "test_db",
      connection: { host: "localhost", port: 3306, database: "mydb" }
    )
    
    assert_equal "mysql2", database.adapter
  end

  test "should return nil for username when missing" do
    database = Database.create!(
      name: "test_db",
      connection: { host: "localhost", port: 3306, database: "mydb" }
    )
    
    assert_nil database.username
  end

  # Edge cases
  test "should handle connection with nil values" do
    database = Database.create!(
      name: "test_db",
      connection: { host: nil, port: nil, database: nil, username: nil, adapter: nil }
    )
    
    assert_equal "localhost", database.host
    assert_equal 3306, database.port
    assert_equal "test_db", database.database_name
    assert_nil database.username
    assert_equal "mysql2", database.adapter
  end

  test "should initialize connection as empty hash on save" do
    database = Database.new(name: "test_db")
    database.save!
    
    assert_not_nil database.connection
    assert_equal({}, database.connection)
  end

  test "should preserve existing connection on save" do
    connection_data = {
      host: "db.example.com",
      port: 5432,
      database: "mydb",
      username: "user",
      adapter: "postgresql"
    }
    
    database = Database.create!(name: "test_db", connection: connection_data)
    database.reload
    
    assert_equal "db.example.com", database.connection["host"]
    assert_equal 5432, database.connection["port"]
    assert_equal "mydb", database.connection["database"]
    assert_equal "user", database.connection["username"]
    assert_equal "postgresql", database.connection["adapter"]
  end

  # Status tests
  test "should show configured status when connection is present" do
    database = Database.create!(
      name: "test_db",
      connection: { host: "localhost", port: 3306, database: "mydb" }
    )
    
    assert_equal "Configured", database.status
    assert_equal "green", database.status_color
  end

  test "should show not configured status when connection is empty" do
    database = Database.create!(name: "test_db", connection: {})
    
    assert_equal "Not Configured", database.status
    assert_equal "yellow", database.status_color
  end

  # Virtual attribute tests
  test "should convert connection to JSON string" do
    database = Database.create!(
      name: "test_db",
      connection: { host: "localhost", port: 3306 }
    )
    
    json_string = database.connection_json
    assert_not_nil json_string
    
    parsed = JSON.parse(json_string)
    assert_equal "localhost", parsed["host"]
    assert_equal 3306, parsed["port"]
  end

  test "should return nil for connection_json when connection is empty" do
    database = Database.create!(name: "test_db", connection: {})
    assert_nil database.connection_json
  end
end
