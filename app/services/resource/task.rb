module Resource
  class Task < Base
    attr_reader :task, :container

    def initialize(cluster_arn, task_arn)
      @task = ecs.describe_tasks(cluster: cluster_arn, tasks: [ task_arn ]).tasks.first
    end

    def container=(container)
      @container = container
    end

    def task_arn
      @task.task_arn
    end

    def task_name
      @task.task_definition_arn.split("/").last
    end

    def task_version
      @task.task_definition_arn.split(":").last.to_i
    end

    def container_instance_arn
      @task.container_instance_arn
    end

    def internal_ip_address
      @container.try("private_ip_address")
    end

    def public_ip_address
      @container.try("public_ip_address")
    end

    def host_port(container_port)
      @task.containers.inject([]) do |array, container|
        port = container.network_bindings.find { |binding| binding.container_port == container_port }&.host_port
        array << port if port
        array
      end&.first
    end
  end
end
