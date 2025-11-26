module Resource
  class Service < Base
    def initialize(cluster_arn, service_arn)
      unless service_arn.blank?
        @service = ecs.describe_services(cluster: cluster_arn, services: [ service_arn ]).services.first
      end
      @tasks = []
      task_arns.each do |task_arn|
        @tasks << Resource::Task.new(cluster_arn, task_arn)
      end
      @settings = {}
    end

    def load_settings(name, path)
      @name = name
      @path = path
      @settings = load_yaml(path.join("service.yml"))
    end

    def service_name
      if @service
        @service.service_name
      else
        @name
      end
    end

    def ecs_service
      @service
    end

    def ecs_service=(value)
      @service = value
    end

    def defined?
      @settings.present?
    end

    def deployed?
      @service.present?
    end

    def service_arn
      @service.try("service_arn")
    end

    def service_arn=(value)
      @service.service_arn = value
    end

    def cluster_arn
      @service.try("cluster_arn")
    end

    def task_definition
      @service.try("task_definition")
    end

    def events
      @service.try("events")
    end

    def tasks
      @tasks
    end

    def settings
      @settings
    end

    def settings=(value)
      @settings = value
    end

    def image
      @settings[:image]
    end

    def registry
      @settings[:registry]
    end

    def version
      @settings[:version]
    end

    def version=(value)
      @settings[:version] = value
    end

    def group
      @settings[:group] ||= "stable"
    end

    def group=(value)
      @settings[:group] = value
    end

    def revision
      @settings[:revision]
    end

    def revision=(value)
      @settings[:revision] = value
    end

    def environment_variables
      @settings[:environment] || {}
    end

    # change from hash -> array of hashes as necessary
    def dns
      if @settings[:dns].is_a?(Array)
        @settings[:dns]
      elsif @settings[:dns].is_a?(Hash)
        [ @settings[:dns] ]
      else
        [ { zone: nil, cname: nil, value: nil } ]
      end
    end

    def dns=(value)
      value ||= [ { zone: nil, cname: nil, value: nil } ]
      if value.is_a?(Array)
        @settings[:dns] = value
      elsif value.is_a?(Hash)
        @settings[:dns] = [ value ]
      end
    end

    def virtual_host
      environment_variables[:virtual_host]
    end

    def virtual_port
      environment_variables[:virtual_port]
    end

    def service_task
      task = @settings[:service_task]
      if task.blank?
        first_definition = task_definitions.keys.first
        first_definition = first_definition.to_s if first_definition.is_a?(Symbol)
        task = first_definition
      end
      task
    end

    def task_definitions
      @settings[:task_definitions]
    end

    def get_task_definition(task_name)
      task_definitions[task_name.to_sym]
    end

    def service_definition
      @settings[:service_definition]
    end

    def service_path
      @path
    end

    def save_settings
      save_yaml(@path, "service.yml", @settings)
    end

    def internal_ip_addresses
      @tasks.map { |t| t.internal_ip_address }
    end

    def public_ip_addresses
      @tasks.map { |t| t.public_ip_address }
    end

    def task_arns
      return [] if @service.blank?
      tasks = ecs.list_tasks(cluster: cluster_arn, service_name: service_name)
      list_task_arns = tasks.task_arns
      until tasks.next_token.nil?
        tasks = ecs.list_tasks(cluster: cluster_arn, service_name: service_name, next_token: tasks.next_token)
        list_task_arns += tasks.task_arns
      end
      list_task_arns
    end

    def register_service_task(version)
      # get task_definition of service_task & update image to required version
      task_definition = get_task_definition(service_task).except(:registered_at, :registered_by)
      task_definition[:container_definitions].first[:image] = registry + (version ? ":" + version : "")
      # update task definition
      resp = ecs.register_task_definition(task_definition)
      task_definition = resp.to_h[:task_definition]
      save_task_definition_response(service_task, task_definition)
      self.version = version
      save_settings
      # return updated task_definition
      task_definition
    end

    def save_task_definition_response(definition_name, response)
      self.revision = response.delete(:revision)
      response.delete(:task_definition_arn)
      response.delete(:status)
      response.delete(:requires_attributes)
      response.delete(:compatibilities)
      task_definitions[definition_name.to_sym] = response
    end

    def create_service
      ecs.create_service(service_definition)
    end

    def update_service
      # update_service requires :service rather than :service_name
      update_params = service_definition.merge(force_new_deployment: true)
      update_params[:service] = update_params.delete(:service_name)
      update_params.delete(:load_balancers)
      update_params.delete(:role)
      # puts "params: #{update_params}"
      ecs.update_service(update_params)
    end

    def api_post(request_uri, content)
      uri = URI.parse(environment_variables[:default_url] + request_uri)
      puts "Target: #{uri}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request["X-BMS-Token"] = ENV["API_KEY"]
      request.body = content

      response = http.request(request)
    end
  end
end
