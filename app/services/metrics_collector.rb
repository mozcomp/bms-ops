class MetricsCollector
  class << self
    # Record HTTP request metrics
    def record_request_time(duration, endpoint, tags = {})
      record_metric(
        name: 'http.request.duration',
        value: duration,
        tags: tags.merge(endpoint: endpoint)
      )
    rescue => e
      LoggingService.log_event(:error, "Failed to record request time metric: #{e.message}", 
                                { error: e.class.name, endpoint: endpoint })
    end

    # Record system resource usage metrics
    def record_resource_usage(cpu_percent, memory_percent, tags = {})
      record_metric(
        name: 'system.cpu.usage',
        value: cpu_percent,
        tags: tags
      )

      record_metric(
        name: 'system.memory.usage',
        value: memory_percent,
        tags: tags
      )
    rescue => e
      LoggingService.log_event(:error, "Failed to record resource usage metrics: #{e.message}", 
                                { error: e.class.name })
    end

    # Record database query metrics
    def record_database_query(duration, query_type, tags = {})
      record_metric(
        name: 'database.query.duration',
        value: duration,
        tags: tags.merge(query_type: query_type)
      )
    rescue => e
      LoggingService.log_event(:error, "Failed to record database query metric: #{e.message}", 
                                { error: e.class.name, query_type: query_type })
    end

    # Record custom application metrics
    def record_custom_metric(name, value, tags = {})
      record_metric(
        name: "app.#{name}",
        value: value,
        tags: tags
      )
    rescue => e
      LoggingService.log_event(:error, "Failed to record custom metric: #{e.message}", 
                                { error: e.class.name, metric_name: name })
    end

    # Record AWS service metrics
    def record_aws_metric(service, operation, duration, success = true, tags = {})
      record_metric(
        name: 'aws.api.duration',
        value: duration,
        tags: tags.merge(
          service: service,
          operation: operation,
          success: success
        )
      )
    rescue => e
      LoggingService.log_event(:error, "Failed to record AWS metric: #{e.message}", 
                                { error: e.class.name, service: service, operation: operation })
    end

    # Batch record multiple metrics
    def record_batch(metrics_data)
      return if metrics_data.blank?

      metrics_to_create = metrics_data.map do |data|
        {
          name: data[:name],
          value: data[:value],
          timestamp: data[:timestamp] || Time.current,
          tags: data[:tags] || {},
          aggregation_period: data[:aggregation_period] || 'raw',
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      Metric.insert_all(metrics_to_create)
      LoggingService.log_event(:info, "Recorded batch of #{metrics_data.size} metrics")
    rescue => e
      LoggingService.log_event(:error, "Failed to record metric batch: #{e.message}", 
                                { error: e.class.name, batch_size: metrics_data&.size })
    end

    # Get current system resource usage
    def collect_system_metrics
      cpu_usage = get_cpu_usage
      memory_usage = get_memory_usage
      disk_usage = get_disk_usage

      record_resource_usage(cpu_usage, memory_usage, { disk_usage: disk_usage })
      
      {
        cpu: cpu_usage,
        memory: memory_usage,
        disk: disk_usage
      }
    rescue => e
      LoggingService.log_event(:error, "Failed to collect system metrics: #{e.message}", 
                                { error: e.class.name })
      nil
    end

    # Clean up old metrics based on retention policy
    def cleanup_old_metrics(retention_days = 30)
      cutoff_date = retention_days.days.ago
      deleted_count = Metric.where('timestamp < ?', cutoff_date).delete_all
      
      LoggingService.log_event(:info, "Cleaned up #{deleted_count} old metrics", 
                                { retention_days: retention_days, cutoff_date: cutoff_date })
      
      deleted_count
    rescue => e
      LoggingService.log_event(:error, "Failed to cleanup old metrics: #{e.message}", 
                                { error: e.class.name })
      0
    end

    private

    # Core metric recording method
    def record_metric(name:, value:, timestamp: nil, tags: {}, aggregation_period: 'raw')
      return unless name.present? && value.present?

      Metric.create!(
        name: name,
        value: value,
        timestamp: timestamp || Time.current,
        tags: tags,
        aggregation_period: aggregation_period
      )
    end

    # System resource collection methods
    def get_cpu_usage
      # Simple CPU usage calculation - in production, use proper system monitoring
      if File.exist?('/proc/loadavg')
        load_avg = File.read('/proc/loadavg').split.first.to_f
        # Convert load average to percentage (rough approximation)
        [load_avg * 100 / `nproc`.to_i, 100.0].min
      else
        # Fallback for non-Linux systems
        rand(10..30) # Mock data for development
      end
    rescue
      rand(10..30) # Fallback mock data
    end

    def get_memory_usage
      if File.exist?('/proc/meminfo')
        meminfo = File.read('/proc/meminfo')
        total = meminfo.match(/MemTotal:\s+(\d+)/)[1].to_f
        available = meminfo.match(/MemAvailable:\s+(\d+)/)[1].to_f
        ((total - available) / total * 100).round(1)
      else
        # Fallback for non-Linux systems
        rand(40..70) # Mock data for development
      end
    rescue
      rand(40..70) # Fallback mock data
    end

    def get_disk_usage
      begin
        # Get disk usage for root filesystem
        df_output = `df -h / | tail -1`.split
        usage_percent = df_output[4].gsub('%', '').to_f
        usage_percent
      rescue
        rand(20..50) # Fallback mock data
      end
    end
  end
end