# Database query instrumentation using ActiveSupport notifications
# This captures all SQL queries and records their execution time as metrics

ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, data|
  # Skip certain queries to reduce noise and prevent infinite loops
  next if skip_query?(data[:sql])
  
  # Calculate query duration in milliseconds
  duration = ((finished - started) * 1000).round(2)
  
  # Extract query information
  query_type = extract_query_type(data[:sql])
  connection_name = data[:connection]&.pool&.db_config&.name || 'unknown'
  
  # Record the database query metric (avoid recursive calls)
  record_database_metric_safely(
    duration,
    query_type,
    {
      connection: connection_name,
      cached: data[:cached] || false,
      transaction_id: data[:transaction_id]
    }
  )
  
  # Record additional database metrics
  record_query_count_metric_safely(query_type)
  
  # Log slow queries for monitoring
  if duration > 1000 # Log queries slower than 1 second
    LoggingService.log_event(:warn, "Slow database query detected", {
      duration_ms: duration,
      query_type: query_type,
      sql: data[:sql]&.truncate(500),
      connection: connection_name
    })
  end
rescue => e
  # Log error but don't break the application
  LoggingService.log_event(:error, "Database instrumentation error: #{e.message}", 
                            { error: e.class.name })
end

# Helper method to skip certain queries
def skip_query?(sql)
  return true if sql.blank?
  
  # Skip schema queries, Rails internal queries, metrics table, and other noise
  skip_patterns = [
    /^PRAGMA/i,
    /^SHOW/i,
    /^DESCRIBE/i,
    /^EXPLAIN/i,
    /information_schema/i,
    /pg_/i,
    /sqlite_/i,
    /^SET/i,
    /^COMMIT/i,
    /^BEGIN/i,
    /^ROLLBACK/i,
    /^SAVEPOINT/i,
    /^RELEASE SAVEPOINT/i,
    /schema_migrations/i,
    /ar_internal_metadata/i,
    /\bmetrics\b/i,  # Skip metrics table to prevent infinite loops
    /\blog_entries\b/i  # Skip log entries table to prevent logging loops
  ]
  
  skip_patterns.any? { |pattern| sql.match?(pattern) }
end

# Helper method to extract query type from SQL
def extract_query_type(sql)
  return 'unknown' if sql.blank?
  
  # Extract the first word (operation type) from the SQL query
  first_word = sql.strip.split(/\s+/).first&.upcase
  
  case first_word
  when 'SELECT' then 'select'
  when 'INSERT' then 'insert'
  when 'UPDATE' then 'update'
  when 'DELETE' then 'delete'
  when 'CREATE' then 'create'
  when 'DROP' then 'drop'
  when 'ALTER' then 'alter'
  when 'TRUNCATE' then 'truncate'
  else first_word&.downcase || 'unknown'
  end
end

# Helper method to record database metrics safely (avoiding infinite loops)
def record_database_metric_safely(duration, query_type, tags)
  # Use direct database insertion to avoid triggering more notifications
  timestamp = Time.current
  
  Metric.connection.execute(<<~SQL)
    INSERT INTO metrics (name, value, timestamp, tags, aggregation_period, created_at, updated_at)
    VALUES (
      'database.query.duration',
      #{duration},
      '#{timestamp.iso8601}',
      '#{tags.to_json.gsub("'", "''")}',
      'raw',
      '#{timestamp.iso8601}',
      '#{timestamp.iso8601}'
    )
  SQL
rescue => e
  # Silently fail to avoid breaking the application
  Rails.logger.error "Failed to record database metric: #{e.message}"
end

# Helper method to record query count metrics safely
def record_query_count_metric_safely(query_type)
  # Use direct database insertion to avoid triggering more notifications
  timestamp = Time.current
  tags = { query_type: query_type }
  
  Metric.connection.execute(<<~SQL)
    INSERT INTO metrics (name, value, timestamp, tags, aggregation_period, created_at, updated_at)
    VALUES (
      'database.query.count',
      1,
      '#{timestamp.iso8601}',
      '#{tags.to_json.gsub("'", "''")}',
      'raw',
      '#{timestamp.iso8601}',
      '#{timestamp.iso8601}'
    )
  SQL
rescue => e
  # Silently fail to avoid breaking the application
  Rails.logger.error "Failed to record query count metric: #{e.message}"
end