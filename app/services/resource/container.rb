module Resource
  class Container < Base
    attr_reader :container, :ec2_instance

    def initialize(cluster_arn, container_arn)
      @container = ecs.describe_container_instances(cluster: cluster_arn, container_instances: [ container_arn ]).container_instances.first
      @ec2_instance = ec2.describe_instances(instance_ids: [ @container.ec2_instance_id ]).reservations.first.instances.first
    end

    def container_arn
      @container.container_instance_arn
    end

    def private_ip_address
      @ec2_instance.private_ip_address
    end

    def public_ip_address
      @ec2_instance.public_ip_address
    end
  end
end
