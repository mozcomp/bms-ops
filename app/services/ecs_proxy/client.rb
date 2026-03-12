module EcsProxy
  class Client
    attr_reader :last_response

    def initialize(proxy_url = nil)
      @proxy_url = proxy_url
    end

    def proxy_url
      @proxy_url ||= "https://proxy.bmserp.com/"
    end

    def token
      ENV["PROXY_TOKEN"]
    end

    def connection
      @connection ||= Faraday.new(url: proxy_url) do |faraday|
        faraday.headers["Authorization"] = "Bearer #{token}"
        faraday.response :json, content_type: /\bjson$/
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def last_response=(value)
      @response = nil
      @last_response = value
    end

    def response
      @response ||= parse_last_response
    end

    def parse_last_response
      return nil if last_response.blank?
      # body already json parsed by Faraday middleware, but we want to symbolize keys and handle parse errors gracefully
      # body = last_response.body
      json = { message: last_response.body.split("\n") }.with_indifferent_access
      json.merge!(success?: last_response.success?, status: last_response.status)
      json[:error] = last_response.reason_phrase if last_response.reason_phrase.present? && !last_response.success?
      OpenStruct.new(json)
    end

    def trigger_reload
      # tell the proxy to reload the config from S3
      self.last_response = connection.put("/internal/reload-config")
      raise "error reloading proxy configuration: #{response.error}" unless response.success?
      response
    end

    def reload_proxy_configuration(services = nil)
      # generate new proxy config to S3
      result = EcsProxy::GenerateConfig.call
      raise "error generating proxy config: #{result.error}" unless result.success?
      # then tell the proxy to reload the config from S3
      trigger_reload
    end
  end
end
