class HealthCheckController < ApplicationController
  allow_unauthenticated_access
  
  # GET /health
  def show
    result = HealthCheckService.check_system_health
    
    status_code = case result[:status]
    when 'healthy'
      200
    when 'unhealthy'
      503
    else
      200 # unknown status still returns 200 but with status info
    end
    
    render json: {
      status: result[:status],
      timestamp: result[:timestamp],
      version: Rails.application.class.module_parent_name,
      environment: Rails.env
    }, status: status_code
  end

  # GET /health/detailed
  def detailed
    result = HealthCheckService.check_system_health
    
    status_code = case result[:status]
    when 'healthy'
      200
    when 'unhealthy'
      503
    else
      200 # unknown status still returns 200 but with status info
    end
    
    render json: {
      status: result[:status],
      timestamp: result[:timestamp],
      version: Rails.application.class.module_parent_name,
      environment: Rails.env,
      checks: result[:checks],
      summary: {
        total_checks: result[:checks].size,
        healthy_checks: result[:checks].count { |_, check| check[:status] == 'healthy' },
        unhealthy_checks: result[:checks].count { |_, check| check[:status] == 'unhealthy' },
        unknown_checks: result[:checks].count { |_, check| check[:status] == 'unknown' }
      }
    }, status: status_code
  end
end