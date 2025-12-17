require "test_helper"

class DatabaseInstrumentationTest < ActiveSupport::TestCase
  test "should record database query metrics" do
    initial_count = Metric.where(name: 'database.query.duration').count
    
    # Execute a simple query that should be instrumented
    User.count
    
    # Should have recorded the query metric
    final_count = Metric.where(name: 'database.query.duration').count
    assert final_count > initial_count, "Should record database query metrics"
  end

  test "should record query count metrics" do
    initial_count = Metric.where(name: 'database.query.count').count
    
    # Execute a simple query
    User.count
    
    # Should have recorded the query count metric
    final_count = Metric.where(name: 'database.query.count').count
    assert final_count > initial_count, "Should record query count metrics"
  end

  test "should skip metrics table queries to prevent infinite loops" do
    initial_count = Metric.count
    
    # This should not trigger additional metrics recording
    Metric.count
    
    # The count should not have increased significantly
    final_count = Metric.count
    assert (final_count - initial_count) <= 1, "Should not create infinite loop with metrics table queries"
  end

  test "should extract query type correctly" do
    # Test the helper method
    assert_equal 'select', extract_query_type('SELECT * FROM users')
    assert_equal 'insert', extract_query_type('INSERT INTO users (name) VALUES (?)')
    assert_equal 'update', extract_query_type('UPDATE users SET name = ?')
    assert_equal 'delete', extract_query_type('DELETE FROM users WHERE id = ?')
  end

  test "should skip schema and internal queries" do
    # Test the helper method
    assert skip_query?('PRAGMA table_info(users)')
    assert skip_query?('SELECT * FROM schema_migrations')
    assert skip_query?('INSERT INTO metrics (name, value) VALUES (?, ?)')
    assert skip_query?('SHOW TABLES')
    
    # Should not skip regular queries
    assert_not skip_query?('SELECT * FROM users')
    assert_not skip_query?('INSERT INTO users (name) VALUES (?)')
  end
end