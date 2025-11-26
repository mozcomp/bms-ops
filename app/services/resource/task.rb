module Resource
  class Task < Base
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
      ports = []
      @task.containers.each do |container|
        container.network_bindings.each do |binding|
          next unless binding.container_port == container_port
          ports << binding.host_port
        end
      end
      ports.first
    end
  end
end
