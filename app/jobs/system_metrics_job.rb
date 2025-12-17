# Background job for periodic system resource monitoring
class SystemMetricsJob < ApplicationJob
  queue_as :default

  # Run every 60 seconds to collect system metrics
  def perform
    collect_system_resources
    collect_application_metrics
    collect_database_metrics
    
    LoggingService.log_event(:debug, "System metrics collection completed")
  rescue => e
    LoggingService.log_event(:error, "System metrics collection failed: #{e.message}", 
                              { error: e.class.name })
    raise # Re-raise to trigger retry mechanism
  end

  private

  def collect_system_resources
    # Collect basic system resource metrics
    metrics = MetricsCollector.collect_system_metrics
    
    return unless metrics
    
    # Record additional system metrics
    record_load_average
    record_disk_io_metrics
    record_network_metrics if respond_to?(:record_network_metrics, true)
  end

  def collect_application_metrics
    # Collect Rails application-specific metrics
    record_active_record_pool_metrics
    record_cache_metrics
    record_queue_metrics
  end

  def collect_database_metrics
    # Collect database-specific metrics
    record_database_connection_metrics
    record_database_size_metrics
  end

  def record_load_average
    if File.exist?('/proc/loadavg')
      load_data = File.read('/proc/loadavg').split
      
      MetricsCollector.record_custom_metric('system.load.1min', load_data[0].to_f)
      MetricsCollector.record_custom_metric('system.load.5min', load_data[1].to_f)
      MetricsCollector.record_custom_metric('system.load.15min', load_data[2].to_f)
    end
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect load average: #{e.message}")
  end

  def record_disk_io_metrics
    # Simple disk I/O metrics (Linux-specific)
    if File.exist?('/proc/diskstats')
      # This is a simplified implementation - in production, you'd want more sophisticated parsing
      diskstats = File.read('/proc/diskstats')
      
      # Count total read/write operations across all disks
      total_reads = 0
      total_writes = 0
      
      diskstats.each_line do |line|
        fields = line.split
        next if fields.size < 14
        
        # Skip loop devices and other virtual devices
        device_name = fields[2]
        next if device_name.match?(/^(loop|ram|dm-)/)
        
        reads = fields[3].to_i
        writes = fields[7].to_i
        
        total_reads += reads
        total_writes += writes
      end
      
      MetricsCollector.record_custom_metric('system.disk.reads', total_reads, { unit: 'operations' })
      MetricsCollector.record_custom_metric('system.disk.writes', total_writes, { unit: 'operations' })
    end
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect disk I/O metrics: #{e.message}")
  end

  def record_active_record_pool_metrics
    # Collect ActiveRecord connection pool metrics
    pool = ActiveRecord::Base.connection_pool
    pool_name = pool.db_config.name
    
    MetricsCollector.record_custom_metric(
      'activerecord.pool.size',
      pool.size,
      { pool: pool_name }
    )
    
    MetricsCollector.record_custom_metric(
      'activerecord.pool.checked_out',
      pool.checked_out_connections.size,
      { pool: pool_name }
    )
    
    MetricsCollector.record_custom_metric(
      'activerecord.pool.available',
      pool.available_connection_count,
      { pool: pool_name }
    )
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect ActiveRecord pool metrics: #{e.message}")
  end

  def record_cache_metrics
    # Collect Rails cache metrics if cache store supports it
    cache_store = Rails.cache
    
    if cache_store.respond_to?(:stats)
      stats = cache_store.stats
      
      stats.each do |key, value|
        next unless value.is_a?(Numeric)
        
        MetricsCollector.record_custom_metric(
          "cache.#{key}",
          value,
          { store: cache_store.class.name }
        )
      end
    end
    
    # Record cache store type
    MetricsCollector.record_custom_metric(
      'cache.store_type',
      1,
      { type: cache_store.class.name }
    )
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect cache metrics: #{e.message}")
  end

  def record_queue_metrics
    # Collect job queue metrics if using a supported adapter
    if defined?(SolidQueue)
      # SolidQueue metrics
      record_solid_queue_metrics
    elsif defined?(Sidekiq)
      # Sidekiq metrics
      record_sidekiq_metrics
    end
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect queue metrics: #{e.message}")
  end

  def record_solid_queue_metrics
    # Basic SolidQueue metrics
    pending_jobs = SolidQueue::Job.pending.count
    running_jobs = SolidQueue::Job.running.count
    failed_jobs = SolidQueue::Job.failed.count
    
    MetricsCollector.record_custom_metric('queue.pending', pending_jobs, { adapter: 'solid_queue' })
    MetricsCollector.record_custom_metric('queue.running', running_jobs, { adapter: 'solid_queue' })
    MetricsCollector.record_custom_metric('queue.failed', failed_jobs, { adapter: 'solid_queue' })
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect SolidQueue metrics: #{e.message}")
  end

  def record_sidekiq_metrics
    # Sidekiq metrics (if available)
    stats = Sidekiq::Stats.new
    
    MetricsCollector.record_custom_metric('queue.pending', stats.enqueued, { adapter: 'sidekiq' })
    MetricsCollector.record_custom_metric('queue.running', stats.processed, { adapter: 'sidekiq' })
    MetricsCollector.record_custom_metric('queue.failed', stats.failed, { adapter: 'sidekiq' })
    MetricsCollector.record_custom_metric('queue.retry', stats.retry_size, { adapter: 'sidekiq' })
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect Sidekiq metrics: #{e.message}")
  end

  def record_database_connection_metrics
    # Database connection metrics
    pool = ActiveRecord::Base.connection_pool
    pool_name = pool.db_config.name
    
    begin
      # Test connection and record response time
      start_time = Time.current
      pool.with_connection { |conn| conn.execute('SELECT 1') }
      response_time = ((Time.current - start_time) * 1000).round(2)
      
      MetricsCollector.record_custom_metric(
        'database.connection.response_time',
        response_time,
        { pool: pool_name, unit: 'ms' }
      )
      
      MetricsCollector.record_custom_metric(
        'database.connection.healthy',
        1,
        { pool: pool_name }
      )
    rescue => e
      MetricsCollector.record_custom_metric(
        'database.connection.healthy',
        0,
        { pool: pool_name, error: e.class.name }
      )
      
      LoggingService.log_event(:error, "Database connection check failed", {
        pool: pool_name,
        error: e.message
      })
    end
  end

  def record_database_size_metrics
    # Database size metrics (implementation varies by database type)
    pool = ActiveRecord::Base.connection_pool
    pool_name = pool.db_config.name
    
    pool.with_connection do |conn|
      case conn.adapter_name.downcase
      when 'sqlite'
        record_sqlite_size_metrics(conn, pool_name)
      when 'postgresql'
        record_postgresql_size_metrics(conn, pool_name)
      when 'mysql2', 'trilogy'
        record_mysql_size_metrics(conn, pool_name)
      end
    end
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect database size metrics: #{e.message}")
  end

  def record_sqlite_size_metrics(connection, pool_name)
    # SQLite database file size
    db_path = connection.instance_variable_get(:@config)[:database]
    
    if File.exist?(db_path)
      size_bytes = File.size(db_path)
      
      MetricsCollector.record_custom_metric(
        'database.size',
        size_bytes,
        { pool: pool_name, unit: 'bytes', type: 'sqlite' }
      )
    end
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect SQLite size metrics: #{e.message}")
  end

  def record_postgresql_size_metrics(connection, pool_name)
    # PostgreSQL database size
    result = connection.execute("SELECT pg_database_size(current_database())")
    size_bytes = result.first['pg_database_size']
    
    MetricsCollector.record_custom_metric(
      'database.size',
      size_bytes,
      { pool: pool_name, unit: 'bytes', type: 'postgresql' }
    )
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect PostgreSQL size metrics: #{e.message}")
  end

  def record_mysql_size_metrics(connection, pool_name)
    # MySQL database size
    database_name = connection.current_database
    
    result = connection.execute(<<~SQL)
      SELECT SUM(data_length + index_length) as size_bytes
      FROM information_schema.tables
      WHERE table_schema = '#{database_name}'
    SQL
    
    size_bytes = result.first['size_bytes'] || 0
    
    MetricsCollector.record_custom_metric(
      'database.size',
      size_bytes,
      { pool: pool_name, unit: 'bytes', type: 'mysql' }
    )
  rescue => e
    LoggingService.log_event(:warn, "Failed to collect MySQL size metrics: #{e.message}")
  end
end