require "pathname"
require "yaml"

class Settings
  def initialize
    unless ENV["BMS_CLI_RESOURCES_PATH"]
      raise "Resources path must be provided. set env BMS_CLI_RESOURCES_PATH"
    end
    if File.exist?(local_config)
      @config_path = local_config
    elsif File.exist?(home_config)
      @config_path = home_config
    elsif File.exist?(app_config)
      @config_path = app_config
    else
      raise "Configuration directory not found.."
    end
    @config_file = @config_path.join("settings.yml")
    @settings = YAML.unsafe_load_file(@config_file)
  end

  def settings
    @settings
  end

  def aws_region
    @settings["aws"]["region"]
  end

  def s3_bucket
    @settings["aws"]["s3_bucket"]
  end

  def ecs_cluster
    @settings["default"]["cluster_name"]
  end

  def resources_path
    @resources_path ||= get_resources_path
  end

  private

  def local_config
    Pathname.new(ENV["PWD"]).join(".bms-cli")
  end

  def app_config
    app = ENV["BMS_CLI"] || ENV["APP_PATH"]
    Pathname.new(app).join("config")
  end

  def home_config
    Pathname.new(ENV["HOME"]).join(".bms-cli")
  end

  def get_resources_path
    path = Pathname.new(ENV["BMS_CLI_RESOURCES_PATH"]) # absolute path to resources folder
    raise "no path to $BMS_CLI_RESOURCES_PATH - #{ENV['BMS_CLI_RESOURCES_PATH']}" unless path.exist?
    path
  end
end
