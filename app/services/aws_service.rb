require "aws-sdk-s3"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-ec2"
require "aws-sdk-ecr"
require "aws-sdk-ecs"
require "aws-sdk-elasticloadbalancingv2"
require "aws-sdk-route53"

module AwsService
  def s3
    @s3 ||= Aws::S3::Resource.new
  end

  def ec2
    @ec2 ||= Aws::EC2::Client.new
  end

  def ecs
    @ecs ||= Aws::ECS::Client.new
  end

  def elb
    @elb ||= Aws::ElasticLoadBalancingV2::Client.new
  end

  def ecr
    @ecr ||= Aws::ECR::Client.new
  end

  def cloudwatchlogs
    @cloudwatchlogs ||= Aws::CloudWatchLogs::Client.new
  end

  def route53
    @route53 ||= Aws::Route53::Client.new
  end
end
