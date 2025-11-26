module Resource
  class Cluster < Base
    def initialize(cluster_name)
      @cluster = ecs.describe_clusters(clusters: [ cluster_name ]).clusters.first
    end

    def cluster_name
      @cluster.cluster_name
    end

    def cluster_arn
      @cluster.cluster_arn
    end
  end
end
