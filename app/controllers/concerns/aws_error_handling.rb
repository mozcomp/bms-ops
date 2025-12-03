# frozen_string_literal: true

module AwsErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from AwsService::CredentialsError, with: :handle_aws_credentials_error
    rescue_from Resources::ConfigurationError, with: :handle_aws_configuration_error
    rescue_from Aws::Errors::ServiceError, with: :handle_aws_service_error
  end

  private

  def handle_aws_credentials_error(exception)
    Rails.logger.error("[AWS Credentials Error] #{exception.message}")
    
    flash[:error] = "AWS credentials are not configured. Please contact your system administrator."
    redirect_to root_path
  end

  def handle_aws_configuration_error(exception)
    Rails.logger.error("[AWS Configuration Error] #{exception.message}")
    
    flash[:error] = "AWS configuration is incomplete. Please contact your system administrator."
    redirect_to root_path
  end

  def handle_aws_service_error(exception)
    Rails.logger.error("[AWS Service Error] #{exception.class}: #{exception.message}")
    
    user_message = case exception
    when Aws::ECS::Errors::ClusterNotFoundException
      "The specified ECS cluster was not found. Please verify your AWS configuration."
    when Aws::ECS::Errors::ServiceNotFoundException
      "The specified ECS service was not found."
    when Aws::ECS::Errors::AccessDeniedException
      "Access denied to AWS resources. Please check your AWS permissions."
    when Aws::ECS::Errors::ThrottlingException
      "AWS request rate limit exceeded. Please try again in a moment."
    when Aws::S3::Errors::NoSuchBucket
      "The specified S3 bucket does not exist."
    when Aws::S3::Errors::AccessDenied
      "Access denied to S3 bucket. Please check your AWS permissions."
    else
      "An error occurred while communicating with AWS: #{exception.message}"
    end
    
    flash[:error] = user_message
    redirect_back fallback_location: root_path
  end
end
