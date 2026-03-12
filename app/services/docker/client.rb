require "ostruct"
module Docker
  class Client
    attr_reader :last_response
    # allow manually setting token for testing purposes, but default to fetching a new token if not set or expired
    attr_writer :token

    API_URL= "https://hub.docker.com"

    def initialize
      token
    end

    def token
      @token ||= get_token
    end

    def get_token
      conn = Faraday.new(url: API_URL) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
      end
      self.last_response = conn.post(
        "#{API_URL}/v2/auth/token/",
        { identifier: ENV["DOCKER_USERNAME"], secret: ENV["DOCKER_TOKEN"] }
      )
      raise "error requesting token: #{response.error}" unless response.success?
      response.access_token
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
      if last_response.body.is_a?(Hash)
        json = last_response.body.with_indifferent_access
      else
        json = (JSON.parse(last_response.body) rescue {}).with_indifferent_access
      end
      json.merge!(success?: last_response.success?, status: last_response.status)
      json[:error] = last_response.reason_phrase if last_response.reason_phrase.present? && !last_response.success?
      json[:error] ||= json[:detail] if json[:detail].present? && !last_response.success?
      OpenStruct.new(json)
    end

    # can only be used once we have a token, else it will cause an infinite loop trying to fetch a token to make the connection in order to fetch a token
    def connection
      @connection ||= Faraday.new(url: API_URL) do |faraday|
        faraday.request :json
        faraday.headers["Authorization"] = "Bearer #{token}"
        faraday.response :json, content_type: /\bjson$/
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def get_repo_details(namespace, repo)
      url = "#{API_URL}/v2/namespaces/#{namespace}/repositories/#{repo}"
      self.last_response = connection.get(url)
      raise "error fetching repository details: #{response.error}" unless response.success?
      response
    end

    def get_repo_tags(namespace, repo, max_tags = 100)
      url = "#{API_URL}/v2/namespaces/#{namespace}/repositories/#{repo}/tags"
      self.last_response = connection.get(url)
      raise "error fetching tags: #{response.error}" unless response.success?
      tags = response.results
      while response.next && tags.size < max_tags
        self.last_response = connection.get(response.next)
        raise "error fetching tags: #{response.error}" unless response.success?
        tags.concat(response.results)
      end
      tags.take(max_tags)&.index_by { |tag| tag[:name] }
    end

    def next_page(next_url)
      self.last_response = connection.get(next_url)
      response
    end
  end
end
