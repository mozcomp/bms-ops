module EcsProxy
  class GenerateConfig
    include Interactor

    before do
      erb = context.template || Rails.root.join("app", "interactors", "ecs_proxy", "nginx.conf.erb")
      erb_path = Pathname.new(erb).exist? ? Pathname.new(erb) : Pathname.new(File.join(__dir__, "../../#{erb}"))
      unless erb_path.exist?
        context.fail!(error: "Template file not found: #{erb}")
      end
      context.renderer = ERB.new(erb_path.open.read, trim_mode: ">")
      context.s3_bucket ||= "bms-ops"
      context.s3_key ||= "ecs-proxy/default.conf"
    end

    def call
      @services = context.services = Resources.new.deployed_services
      context.config = context.renderer.result(binding)
      client = Aws::S3::Client.new(region: ENV["AWS_REGION"])
      client.put_object(
        bucket: context.s3_bucket,
        key: context.s3_key,
        body: context.config
      )
    end
  end
end
