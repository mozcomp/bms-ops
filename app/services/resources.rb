# require "pathname"
# require "resource/base"
# require "resource/cluster"
# require "resource/container"
# require "resource/image"
# require "resource/service"
# require "resource/task"
# require "resource/template"
# require "resource/zone"

class Resources
  include AwsService

  class ConfigurationError < StandardError; end

  def initialize
    @settings = Settings.new

    unless @settings.ecs_cluster.present?
      log_error("Missing cluster configuration")
      raise ConfigurationError, "No cluster_name in settings. Please configure the ECS cluster name."
    end

    log_operation("Initializing Resources for cluster: #{@settings.ecs_cluster}")
    @cluster = Resource::Cluster.new(@settings.ecs_cluster)
    @services ||= service_arns.inject([]) { |array, service_arn| array << Resource::Service.new(cluster_arn, service_arn); array }
    @containers ||= container_arns.inject([]) { |array, container_arn| array << Resource::Container.new(cluster_arn, container_arn); array }

    @services.each do |service|
      service.tasks.each do |task|
        task.container = container(task.container_instance_arn)
      end
    end

    raise "Resources path not set" unless resources_path.exist?

    services_path = resources_path.join("services")
    services_path.each_child do |path|
      next unless path.directory?
      next unless path.join("service.yml").file?
      service = @services.find { |s| s.service_name == path.basename.to_s }
      @services << service = Resource::Service.new(cluster_arn, nil) if service.blank?
      service.load_settings(path.basename.to_s, path)
    end

    @services = @services.sort_by(&:service_name)

    @images = []
    images_path = resources_path.join("images")
    images_path.each_child do |path|
      next unless path.directory?
      @images << Resource::Image.new(path, path.basename.to_s)
    end

    @zones = []
    zones_path = resources_path.join("zones")
    zones_path.each_child do |path|
      next unless path.file?
      next if path.basename.to_s == ".keep"
      @zones << Resource::Zone.new(path)
    end
  end

  def s3_resources_bucket
    @settings.s3_bucket
  end

  def resources_path
    @settings.resources_path
  end

  def cluster
    @cluster
  end

  def cluster_arn
    @cluster.try("cluster_arn")
  end

  def services
    @services
  end

  def service(name)
    @services.find { |s| s.service_name == name }
  end

  def images
    @images
  end

  def image(name)
    @images.find { |i| i.name == name }
  end

  def zones
    @zones
  end

  def zone(name)
    @zones.find { |z| z.name == name }
  end

  def containers
    @containers
  end

  def container(arn)
    containers.find { |c| c.container_arn == arn }
  end

  def deployed_services
    deployed_services = []
    services.each do |service|
      next unless service.deployed?
      next if service.virtual_host.blank? || service.virtual_port.blank?
      deployed_service = {
        service_name:   service.service_name,
        service_url:    service.virtual_host,
        ports:          []
      }
      service.tasks.each do |task|
        next if task.internal_ip_address.blank? || task.host_port(service.virtual_port.to_i).blank?
        deployed_service[:ports] << "#{task.internal_ip_address}:#{task.host_port(service.virtual_port.to_i)}"
      end
      deployed_services << deployed_service if deployed_service[:ports].any?
    end
    deployed_services
  end

  def service_arns
    if cluster_arn.blank?
      log_error("Cannot list services: cluster_arn is blank")
      return []
    end

    log_operation("Fetching service ARNs for cluster: #{cluster_arn}")
    list_service_arns = []
    next_token = nil

    begin
      loop do
        params = { cluster: cluster_arn }
        params[:next_token] = next_token if next_token

        response = ecs.list_services(params)
        list_service_arns += response.service_arns
        next_token = response.next_token

        log_operation("Fetched #{response.service_arns.size} service ARNs (total: #{list_service_arns.size})")

        break if next_token.nil?
      end
    rescue StandardError => e
      log_error("Failed to fetch service ARNs", e)
      raise
    end

    log_operation("Completed fetching #{list_service_arns.size} service ARNs")
    list_service_arns
  end

  def container_arns
    if cluster_arn.blank?
      log_error("Cannot list containers: cluster_arn is blank")
      return []
    end

    log_operation("Fetching container instance ARNs for cluster: #{cluster_arn}")
    list_container_arns = []
    next_token = nil

    begin
      loop do
        params = { cluster: cluster_arn }
        params[:next_token] = next_token if next_token

        response = ecs.list_container_instances(params)
        list_container_arns += response.container_instance_arns
        next_token = response.next_token

        log_operation("Fetched #{response.container_instance_arns.size} container ARNs (total: #{list_container_arns.size})")

        break if next_token.nil?
      end
    rescue StandardError => e
      log_error("Failed to fetch container instance ARNs", e)
      raise
    end

    log_operation("Completed fetching #{list_container_arns.size} container instance ARNs")
    list_container_arns
  end

  def save_resources_to_s3
  end

  def restore_resources_from_s3
  end

  private

  def log_operation(message)
    Rails.logger.info("[Resources] #{message}") if defined?(Rails)
  end

  def log_error(message, error = nil)
    if defined?(Rails)
      if error
        Rails.logger.error("[Resources ERROR] #{message}: #{error.class} - #{error.message}")
      else
        Rails.logger.error("[Resources ERROR] #{message}")
      end
    end
  end
end
