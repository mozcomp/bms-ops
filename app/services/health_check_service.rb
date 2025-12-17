class HealthCheckService
  include AwsService
  
  TIMEOUT = 5.seconds

  def self.check_system_health
    new.check_system_health
  end

  def check_system_health
    checks = {}
    overall_status = 'healthy'

    # Run all health checks
    checks[:database] = check_database
    checks[:disk_space] = check_disk_space
    checks[:external_services] = check_external_services

    # Determine overall status
    if checks.values.any? { |check| check[:status] == 'unhealthy' }
      overall_status = 'unhealthy'
    elsif checks.values.any? { |check| check[:status] == 'unknown' }
      overall_status = 'unknown'
    end

    # Store health check results
    store_health_checks(checks)

    {
      status: overall_status,
      timestamp: Time.current,
      checks: checks
    }
  end

  def check_database
    start_time = Time.current
    
    begin
      Timeout.timeout(TIMEOUT) do
        # Test database connectivity with a simple query
        ActiveRecord::Base.connection.execute("SELECT 1")
        
        # Test that we can read from a table
        User.limit(1).count
        
        response_time = ((Time.current - start_time) * 1000).round(2)
        
        {
          status: 'healthy',
          response_time_ms: response_time,
          message: 'Database connection successful',
          details: {
            adapter: ActiveRecord::Base.connection.adapter_name,
            database: database_name
          }
        }
      end
    rescue Timeout::Error
      {
        status: 'unhealthy',
        response_time_ms: (TIMEOUT * 1000).to_i,
        message: 'Database connection timeout',
        error: 'Connection timed out after 5 seconds'
      }
    rescue => e
      {
        status: 'unhealthy',
        response_time_ms: ((Time.current - start_time) * 1000).round(2),
        message: 'Database connection failed',
        error: e.message
      }
    end
  end

  def check_disk_space
    start_time = Time.current
    
    begin
      # Check available disk space using df command (cross-platform)
      df_output = `df -h #{Rails.root}`.lines.last
      usage_info = df_output.split
      used_percentage = usage_info[4].to_i # Remove % and convert to integer
      
      status = if used_percentage > 90
        'unhealthy'
      elsif used_percentage > 80
        'unknown'
      else
        'healthy'
      end
      
      response_time = ((Time.current - start_time) * 1000).round(2)
      
      {
        status: status,
        response_time_ms: response_time,
        message: "Disk usage: #{used_percentage}%",
        details: {
          filesystem: usage_info[0],
          size: usage_info[1],
          used: usage_info[2],
          available: usage_info[3],
          used_percentage: used_percentage,
          mount_point: usage_info[5]
        }
      }
    rescue => e
      {
        status: 'unknown',
        response_time_ms: ((Time.current - start_time) * 1000).round(2),
        message: 'Unable to check disk space',
        error: e.message
      }
    end
  end

  def check_external_services
    start_time = Time.current
    
    begin
      # Check AWS connectivity if configured
      if aws_configured?
        check_aws_connectivity
      else
        {
          status: 'unknown',
          response_time_ms: ((Time.current - start_time) * 1000).round(2),
          message: 'AWS not configured',
          details: { configured: false }
        }
      end
    rescue => e
      {
        status: 'unhealthy',
        response_time_ms: ((Time.current - start_time) * 1000).round(2),
        message: 'External service check failed',
        error: e.message
      }
    end
  end

  private

  def aws_configured?
    ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present?
  end

  def check_aws_connectivity
    start_time = Time.current
    
    begin
      Timeout.timeout(TIMEOUT) do
        # Try to list ECS clusters as a basic connectivity test
        ecs_client = ecs
        result = ecs_client.list_clusters(max_results: 1)
        
        response_time = ((Time.current - start_time) * 1000).round(2)
        
        {
          status: 'healthy',
          response_time_ms: response_time,
          message: 'AWS connectivity successful',
          details: {
            service: 'AWS ECS',
            region: ecs_client.config.region,
            clusters_found: result.cluster_arns.size
          }
        }
      end
    rescue Timeout::Error
      {
        status: 'unhealthy',
        response_time_ms: (TIMEOUT * 1000).to_i,
        message: 'AWS connectivity timeout',
        error: 'AWS API call timed out after 5 seconds'
      }
    rescue AwsService::CredentialsError => e
      {
        status: 'unknown',
        response_time_ms: ((Time.current - start_time) * 1000).round(2),
        message: 'AWS credentials not configured',
        error: e.message
      }
    rescue => e
      {
        status: 'unhealthy',
        response_time_ms: ((Time.current - start_time) * 1000).round(2),
        message: 'AWS connectivity failed',
        error: e.message
      }
    end
  end

  def store_health_checks(checks)
    timestamp = Time.current
    
    checks.each do |name, result|
      HealthCheck.create!(
        name: name.to_s,
        status: result[:status],
        checked_at: timestamp,
        details: result
      )
    end
  rescue => e
    # Log error but don't fail the health check
    Rails.logger.error "Failed to store health check results: #{e.message}"
  end

  def database_name
    case ActiveRecord::Base.connection.adapter_name.downcase
    when 'sqlite'
      File.basename(ActiveRecord::Base.connection_db_config.database)
    when 'mysql2', 'trilogy'
      ActiveRecord::Base.connection_db_config.database
    when 'postgresql'
      ActiveRecord::Base.connection_db_config.database
    else
      'unknown'
    end
  end
end