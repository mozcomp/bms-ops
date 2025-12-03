# Property-based testing helper utilities
require "rantly"
require "rantly/property"
require "rantly/shrinks"

module PropertyTestHelper
  # Default number of iterations for property tests (minimum 100 as per design doc)
  DEFAULT_ITERATIONS = 100

  # Helper method to run property tests with consistent configuration
  def property_of(description, iterations: DEFAULT_ITERATIONS, &block)
    helper = self
    Rantly(iterations) do
      helper.instance_exec(self, &block)
    end
  end

  # Generators for common data types used across the application
  # These generators use Rantly internally and can be called directly from tests

  # Generate a random valid tenant code (alphanumeric, 3-10 characters)
  def generate_tenant_code
    Rantly { sized(range(3, 10)) { string(:alnum) } }
  end

  # Generate a random tenant name
  def generate_tenant_name
    Rantly { sized(range(5, 30)) { string(:alpha) } }.capitalize
  end

  # Generate a random subdomain (lowercase alphanumeric with hyphens)
  def generate_subdomain
    parts = Rantly { array(range(1, 3)) { sized(range(3, 8)) { string(:lower) } } }
    parts.join("-")
  end

  # Generate a random database name
  def generate_database_name
    prefix = "bms"
    tenant = Rantly { sized(range(3, 10)) { string(:alnum) } }.downcase
    env = Rantly { choose("production", "staging", "development") }
    "#{prefix}_#{tenant}_#{env}"
  end

  # Generate a random service name
  def generate_service_name
    prefix = "bms"
    tenant = Rantly { sized(range(3, 10)) { string(:alnum) } }.downcase
    suffix = SecureRandom.hex(4)
    "#{prefix}-#{tenant}-service-#{suffix}"
  end

  # Generate a random AWS region
  def generate_aws_region
    Rantly {
      choose(
        "us-east-1", "us-west-2", "eu-west-1", "eu-central-1",
        "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
      )
    }
  end

  # Generate a random S3 bucket name
  def generate_s3_bucket
    parts = Rantly { array(range(2, 4)) { sized(range(3, 8)) { string(:lower) } } }
    parts.join("-")
  end

  # Generate tenant configuration JSON
  def generate_tenant_configuration
    {
      subdomain: generate_subdomain,
      database: generate_database_name,
      service_name: generate_service_name,
      ses_region: generate_aws_region,
      s3_bucket: generate_s3_bucket
    }
  end

  # Generate a random app name
  def generate_app_name
    words = Rantly { array(range(1, 3)) { sized(range(4, 10)) { string(:alpha) } } }
    words.map(&:capitalize).join(" ")
  end

  # Generate a random repository owner/organization name
  def generate_repo_owner
    Rantly { sized(range(3, 20)) { string(:alnum) } }
  end

  # Generate a random repository name
  def generate_repo_name
    parts = Rantly { array(range(1, 3)) { sized(range(3, 10)) { string(:lower) } } }
    parts.join("-")
  end

  # Generate a random repository platform
  def generate_repo_platform
    Rantly { choose("github.com", "gitlab.com", "bitbucket.org") }
  end

  # Generate a random repository URL in various formats
  def generate_repository_url(format: nil)
    platform = generate_repo_platform
    owner = generate_repo_owner
    repo = generate_repo_name
    
    format ||= Rantly { choose(:https, :ssh, :https_with_git, :ssh_with_git) }
    
    case format
    when :https
      "https://#{platform}/#{owner}/#{repo}"
    when :ssh
      "git@#{platform}:#{owner}/#{repo}"
    when :https_with_git
      "https://#{platform}/#{owner}/#{repo}.git"
    when :ssh_with_git
      "git@#{platform}:#{owner}/#{repo}.git"
    end
  end

  # Generate a random service image name
  def generate_image_name
    parts = Rantly { array(range(1, 2)) { sized(range(3, 10)) { string(:lower) } } }
    parts.join("-")
  end

  # Generate a random Docker registry
  def generate_registry
    region = generate_aws_region
    Rantly {
      choose(
        "docker.io",
        "ghcr.io",
        "#{integer(12)}.dkr.ecr.#{region}.amazonaws.com"
      )
    }
  end

  # Generate a random semantic version
  def generate_version
    Rantly {
      major = integer(10)
      minor = integer(20)
      patch = integer(50)
      "#{major}.#{minor}.#{patch}"
    }
  end

  # Generate service environment variables JSON
  def generate_service_environment
    db_name = generate_database_name
    redis_db = Rantly { integer(15) }
    env = Rantly { choose("production", "staging", "development") }
    secret = Rantly { sized(64) { string(:alnum) } }
    
    {
      "DATABASE_URL" => "mysql2://user:pass@localhost:3306/#{db_name}",
      "REDIS_URL" => "redis://localhost:6379/#{redis_db}",
      "RAILS_ENV" => env,
      "SECRET_KEY_BASE" => secret
    }
  end

  # Generate database connection JSON
  def generate_database_connection
    host = Rantly { choose("localhost", "127.0.0.1", "db.example.com") }
    port = Rantly { choose(3306, 5432, 3307) }
    username = Rantly { sized(range(5, 15)) { string(:alnum) } }
    adapter = Rantly { choose("mysql2", "postgresql", "trilogy") }
    
    {
      host: host,
      port: port,
      database: generate_database_name,
      username: username,
      adapter: adapter
    }
  end

  # Generate a random environment type
  def generate_environment
    Rantly { choose("production", "staging", "development") }
  end

  # Generate a random virtual host
  def generate_virtual_host(environment: nil, subdomain: nil)
    env = environment || generate_environment
    sub = subdomain || generate_subdomain
    
    if env == "production"
      "#{sub}.bmserp.com"
    else
      "#{env}-#{sub}.bmserp.com"
    end
  end

  # Generate instance environment variables JSON
  def generate_instance_env_vars
    db_name = generate_database_name
    env = generate_environment
    secret = Rantly { sized(64) { string(:alnum) } }
    region = generate_aws_region
    bucket = generate_s3_bucket
    code = generate_tenant_code
    
    {
      "DATABASE_URL" => "mysql2://user:pass@localhost:3306/#{db_name}",
      "REDIS_URL" => "redis://localhost:6379/0",
      "RAILS_ENV" => env,
      "SECRET_KEY_BASE" => secret,
      "AWS_REGION" => region,
      "S3_BUCKET" => bucket,
      "TENANT_CODE" => code
    }
  end

  # Generate invalid JSON string (for error handling tests)
  def generate_invalid_json
    Rantly {
      choose(
        "{invalid json}",
        "{'single': 'quotes'}",
        "{missing: quotes}",
        "{\"unclosed\": ",
        "not json at all",
        ""
      )
    }
  end

  # Generate a random string that should fail validation
  def generate_invalid_repository_url
    Rantly {
      choose(
        "not a url",
        "ftp://invalid.com/repo",
        "http://missing-owner.com/",
        "just-text",
        "",
        "https://",
        "git@incomplete"
      )
    }
  end

  # Helper to create a valid tenant with random data
  def create_random_tenant
    Tenant.create!(
      code: generate_tenant_code,
      name: generate_tenant_name,
      configuration: generate_tenant_configuration
    )
  end

  # Helper to create a valid app with random data
  def create_random_app
    App.create!(
      name: generate_app_name,
      repository: generate_repository_url
    )
  end

  # Helper to create a valid service with random data
  def create_random_service
    Service.create!(
      name: generate_service_name,
      image: generate_image_name,
      registry: generate_registry,
      version: generate_version,
      environment: generate_service_environment
    )
  end

  # Helper to create a valid database with random data
  def create_random_database
    Database.create!(
      name: generate_database_name,
      connection: generate_database_connection
    )
  end

  # Helper to create a valid instance with random data
  def create_random_instance(tenant: nil, app: nil, service: nil)
    tenant ||= create_random_tenant
    app ||= create_random_app
    service ||= create_random_service
    
    Instance.create!(
      tenant: tenant,
      app: app,
      service: service,
      environment: generate_environment,
      virtual_host: generate_virtual_host
    )
  end
end
