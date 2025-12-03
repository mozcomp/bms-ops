require "test_helper"

class DatabasePropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 13: Database connection string format
  # Validates: Requirements 4.3
  test "database connection string format is correct for all valid connections" do
    100.times do
      # Generate random connection data
      host = Rantly { choose("localhost", "127.0.0.1", "db.example.com", "mysql.prod.internal") }
      port = Rantly { choose(3306, 5432, 3307, 1433) }
      db_name = generate_database_name
      username = Rantly { sized(range(5, 15)) { string(:alnum) } }
      adapter = Rantly { choose("mysql2", "postgresql", "trilogy", "sqlite3") }
      
      connection_data = {
        host: host,
        port: port,
        database: db_name,
        username: username,
        adapter: adapter
      }
      
      # Create database with connection data
      database = Database.create!(
        name: generate_database_name,
        connection: connection_data
      )
      
      # Verify connection string format: "adapter://username@host:port/database"
      expected_format = "#{adapter}://#{username}@#{host}:#{port}/#{db_name}"
      assert_equal expected_format, database.connection_string,
        "Connection string should be formatted as adapter://username@host:port/database"
      
      # Verify all components are present in the connection string
      assert database.connection_string.include?(adapter), "Connection string should include adapter"
      assert database.connection_string.include?(username), "Connection string should include username"
      assert database.connection_string.include?(host), "Connection string should include host"
      assert database.connection_string.include?(port.to_s), "Connection string should include port"
      assert database.connection_string.include?(db_name), "Connection string should include database name"
      
      # Verify format structure
      assert database.connection_string.start_with?("#{adapter}://"), "Should start with adapter://"
      assert database.connection_string.include?("@"), "Should contain @ separator"
      assert database.connection_string.include?(":"), "Should contain : separator"
      assert database.connection_string.include?("/"), "Should contain / separator"
      
      # Clean up
      database.destroy!
    end
  end
end
