require "test_helper"

class AwsErrorHandlingTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    def trigger_credentials_error
      raise AwsService::CredentialsError, "AWS credentials not configured"
    end

    def trigger_configuration_error
      raise Resources::ConfigurationError, "Cluster name not configured"
    end

    def trigger_service_error
      raise Aws::ECS::Errors::ClusterNotFoundException.new(nil, "Cluster not found")
    end
  end

  setup do
    Rails.application.routes.draw do
      get "test/credentials_error" => "aws_error_handling_test/test#trigger_credentials_error"
      get "test/configuration_error" => "aws_error_handling_test/test#trigger_configuration_error"
      get "test/service_error" => "aws_error_handling_test/test#trigger_service_error"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "handles AWS credentials error gracefully" do
    get "/test/credentials_error"
    
    assert_redirected_to root_path
    follow_redirect!
    assert_match /AWS credentials are not configured/, flash[:error]
  end

  test "handles AWS configuration error gracefully" do
    get "/test/configuration_error"
    
    assert_redirected_to root_path
    follow_redirect!
    assert_match /AWS configuration is incomplete/, flash[:error]
  end

  test "handles AWS service error gracefully" do
    get "/test/service_error"
    
    assert_response :redirect
    assert_match /ECS cluster was not found/, flash[:error]
  end
end
