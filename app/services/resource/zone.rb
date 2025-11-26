module Resource
  class Zone < Base
    include AwsService

    def initialize(path)
      @path = path
      @settings = load_yaml(path)
    end

    def name
      @settings[:name]
    end

    def id
      @settings[:id]
    end

    def set_cname(dns)
      request = {
        hosted_zone_id: id,
        change_batch: {
          comment: "ELB for domain",
          changes: [
            {
              action: "UPSERT",
              resource_record_set: {
                name: dns[:cname],
                type: "CNAME",
                ttl: 300,
                resource_records: [
                  {
                    value: dns[:value]
                  } ]
              }
            } ]
        }
      }
      puts "request: #{request}"
      route53.change_resource_record_sets(request).to_hash
    end
  end
end
