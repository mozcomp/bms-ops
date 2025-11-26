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

  def initialize
    @settings = Settings.new

    raise "No cluster_name in settings" unless @settings.ecs_cluster.present?
    @cluster = Resource::Cluster.new(@settings.ecs_cluster)

    @services = []
    service_arns.each do |service_arn|
      @services << Resource::Service.new(cluster_arn, service_arn)
    end

    @containers = []
    container_arns.each do |container_arn|
      @containers << Resource::Container.new(cluster_arn, container_arn)
    end

    @services.each do |service|
      service.tasks.each do |task|
        task.container = container_instance(task.container_instance_arn)
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

  def container_instance(arn)
    container = containers.find { |container| container.container_arn == arn }
    container
  end

  def deployed_services
    deployed_services = []
    @services.each do |service|
      next unless service.deployed?
      next if service.virtual_host.blank?
      deployed_service = {
        service_name:   service.service_name,
        service_url:    service.virtual_host,
        ports:          []
      }
      service.tasks.each do |task|
        deployed_service[:ports] << "#{task.internal_ip_address}:#{task.host_port(service.virtual_port)}"
      end
      deployed_services << deployed_service
    end
    deployed_services
  end

  def service_arns
    return [] if cluster_arn.blank?
    services = ecs.list_services(cluster: cluster_arn)
    list_service_arns = services.service_arns
    while services.next_token != nil
      services = ecs.list_services(cluster: cluster_arn, next_token: services.next_token)
      list_service_arns += services.service_arns
    end
    list_service_arns
  end

  def container_arns
    return [] if cluster_arn.blank?
    containers = ecs.list_container_instances(cluster: cluster_arn)
    list_container_arns = containers.container_instance_arns
    while containers.next_token != nil
      containers = ecs.list_container_instances(cluster: cluster_arn, next_token: containers.next_token)
      list_container_arns += containers.container_instance_arns
    end
    list_container_arns
  end

  def save_resources_to_s3
  end

  def restore_resources_from_s3
  end
end
