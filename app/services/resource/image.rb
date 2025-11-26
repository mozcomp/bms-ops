module Resource
  class Image < Base
    def initialize(path, name)
      @name = name
      @path = path
      @settings = load_yaml(path.join("image.yml"))
      @settings[:service] = load_yaml(path.join("service.yml"))
      @name ||= @settings[:name]
    end

    def name
      @name
    end

    def path
      @path
    end

    def settings
      @settings ||= {}
    end

    def settings=(value)
      @settings = value
    end

    def version
      @settings[:version]
    end

    def version=(value)
      @settings[:version] = value
    end

    def service
      @settings[:service]
    end

    def service=(value)
      @settings[:service] = value
    end

    def save_settings
      save_yaml(@path, "service.yml", @settings.delete(:service))
      save_yaml(@path, "image.yml", @settings)
    end

    def deployed_services(services)
      # create matrix of version: [service_name, service_name]
      versions = []
      services.each do |service|
        next unless service.image == @settings[:repo]
        version = versions.find { |v| v[:version] == service.version }
        versions << version = { version: service.version, services: [] } if version.blank?
        version[:services] << service.service_name
      end
      versions
    end

    def service_name_from_variables(variables = {})
      return nil if @settings[:service_name].blank?
      variables = symbolize_variables(variables)
      variables = default_variables(variables)
      service_name = @settings[:service_name]
      variables.each do |var, value|
        service_name.gsub!(Regexp.new("<<#{var}>>"), value)
      end
      service_name
    end

    def variables_from_service_name(service_name, variables)
      return variables if service_name.blank?
      variables = symbolize_variables(variables)
      name_parts = service_name.split("-")
      if name_parts.size >= 3 && name_parts[0] == "bms"
        variables[:domain] = name_parts[1] if variables[:domain].blank?
      end
      if ([ "production", "staging", "development" ]).include?(name_parts.last)
        variables[:environment] = name_parts.last if variables[:environment].blank?
      end
      variables
    end

    def new_service(service_name, variables = {})
      variables = symbolize_variables(variables)
      service = @settings[:service].to_yaml
      variables.each do |var, value|
        service.gsub!(Regexp.new("<<#{var}>>"), value)
        service.gsub!(Regexp.new("<<#{var.upcase}>>"), value.upcase)
      end
      symbolize_recursive(YAML.load(service))
    end

    def symbolize_variables(variables)
      variables.keys.each do |key|
        variables[key.to_sym] = variables.delete(key) unless key.is_a?(Symbol)
      end
      variables
    end

    def default_variables(variables)
      @settings[:variables].each do |var, default|
        variables[var] = default if variables[var].blank?
      end
      variables
    end
  end
end
