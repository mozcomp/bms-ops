require "aws-sdk-s3"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-ec2"
require "aws-sdk-ecr"
require "aws-sdk-ecs"
require "aws-sdk-elasticloadbalancingv2"
require "aws-sdk-route53"

module AwsService
  class CredentialsError < StandardError; end

  def s3
    @s3 ||= initialize_client(:s3) { Aws::S3::Resource.new }
  end

  def ec2
    @ec2 ||= initialize_client(:ec2) { Aws::EC2::Client.new }
  end

  def ecs
    @ecs ||= initialize_client(:ecs) { Aws::ECS::Client.new }
  end

  def elb
    @elb ||= initialize_client(:elb) { Aws::ElasticLoadBalancingV2::Client.new }
  end

  def ecr
    @ecr ||= initialize_client(:ecr) { Aws::ECR::Client.new }
  end

  def cloudwatchlogs
    @cloudwatchlogs ||= initialize_client(:cloudwatchlogs) { Aws::CloudWatchLogs::Client.new }
  end

  def route53
    @route53 ||= initialize_client(:route53) { Aws::Route53::Client.new }
  end

  private

  def initialize_client(service_name)
    verify_aws_credentials!
    log_aws_operation("Initializing #{service_name} client")
    yield
  rescue Aws::Errors::MissingCredentialsError => e
    log_aws_error("Missing AWS credentials for #{service_name}", e)
    raise CredentialsError, "AWS credentials are not configured. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
  rescue StandardError => e
    log_aws_error("Failed to initialize #{service_name} client", e)
    raise
  end

  def verify_aws_credentials!
    return if credentials_configured?
    raise CredentialsError, "AWS credentials are not configured. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
  end

  def credentials_configured?
    ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_SECRET_ACCESS_KEY"].present?
  end

  def log_aws_operation(message)
    Rails.logger.info("[AWS] #{message}") if defined?(Rails)
  end

  def log_aws_error(message, error)
    if defined?(Rails)
      Rails.logger.error("[AWS ERROR] #{message}: #{error.class} - #{error.message}")
    end
  end
end
