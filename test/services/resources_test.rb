require "test_helper"

class ResourcesTest < ActiveSupport::TestCase
  # Mock ECS response for testing
  class MockEcsResponse
    attr_reader :service_arns, :container_instance_arns, :next_token
    
    def initialize(arns, next_token = nil)
      @service_arns = arns[:service_arns] || []
      @container_instance_arns = arns[:container_instance_arns] || []
      @next_token = next_token
    end
  end
  
  # Mock ECS client for testing
  class MockEcsClient
    attr_accessor :responses
    
    def initialize
      @responses = []
      @call_index = 0
    end
    
    def list_services(params)
      response = @responses[@call_index]
      @call_index += 1
      response
    end
    
    def list_container_instances(params)
      response = @responses[@call_index]
      @call_index += 1
      response
    end
  end
  
  # Minimal Resources class for testing pagination logic
  class TestableResources
    include AwsService
    
    attr_accessor :mock_ecs_client, :test_cluster_arn
    
    def initialize(cluster_arn)
      @test_cluster_arn = cluster_arn
    end
    
    def cluster_arn
      @test_cluster_arn
    end
    
    def ecs
      @mock_ecs_client ||= MockEcsClient.new
    end
    
    # Copy the actual pagination logic from Resources class
    def service_arns
      if cluster_arn.blank?
        log_error("Cannot list services: cluster_arn is blank")
        return []
      end
      
      list_service_arns = []
      next_token = nil
      
      begin
        loop do
          params = { cluster: cluster_arn }
          params[:next_token] = next_token if next_token
          
          response = ecs.list_services(params)
          list_service_arns += response.service_arns
          next_token = response.next_token
          
          break if next_token.nil?
        end
      rescue StandardError => e
        log_error("Failed to fetch service ARNs", e)
        raise
      end
      
      list_service_arns
    end
    
    def container_arns
      if cluster_arn.blank?
        log_error("Cannot list containers: cluster_arn is blank")
        return []
      end
      
      list_container_arns = []
      next_token = nil
      
      begin
        loop do
          params = { cluster: cluster_arn }
          params[:next_token] = next_token if next_token
          
          response = ecs.list_container_instances(params)
          list_container_arns += response.container_instance_arns
          next_token = response.next_token
          
          break if next_token.nil?
        end
      rescue StandardError => e
        log_error("Failed to fetch container instance ARNs", e)
        raise
      end
      
      list_container_arns
    end
    
    private
    
    def log_error(message, error = nil)
      # No-op for testing
    end
  end
  
  setup do
    @original_access_key = ENV["AWS_ACCESS_KEY_ID"]
    @original_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
    ENV["AWS_ACCESS_KEY_ID"] = "test_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret"
  end
  
  teardown do
    ENV["AWS_ACCESS_KEY_ID"] = @original_access_key
    ENV["AWS_SECRET_ACCESS_KEY"] = @original_secret_key
  end
  
  test "service_arns handles single page response" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock single page response
    arns = ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-1"]
    resources.mock_ecs_client = MockEcsClient.new
    resources.mock_ecs_client.responses = [
      MockEcsResponse.new({ service_arns: arns }, nil)
    ]
    
    result = resources.service_arns
    
    assert_equal 1, result.size
    assert_equal arns, result
  end
  
  test "service_arns handles multiple page responses" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock multi-page response
    page1 = ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-1"]
    page2 = ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-2"]
    page3 = ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-3"]
    
    resources.mock_ecs_client = MockEcsClient.new
    resources.mock_ecs_client.responses = [
      MockEcsResponse.new({ service_arns: page1 }, "token-1"),
      MockEcsResponse.new({ service_arns: page2 }, "token-2"),
      MockEcsResponse.new({ service_arns: page3 }, nil)
    ]
    
    result = resources.service_arns
    
    assert_equal 3, result.size
    assert_equal page1 + page2 + page3, result
  end
  
  test "service_arns returns empty array when cluster_arn is blank" do
    resources = TestableResources.new(nil)
    
    result = resources.service_arns
    
    assert_equal [], result
  end
  
  test "service_arns returns empty array when cluster_arn is empty string" do
    resources = TestableResources.new("")
    
    result = resources.service_arns
    
    assert_equal [], result
  end
  
  test "container_arns handles single page response" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock single page response
    arns = ["arn:aws:ecs:us-east-1:123456789012:container-instance/cluster/abc123"]
    resources.mock_ecs_client = MockEcsClient.new
    resources.mock_ecs_client.responses = [
      MockEcsResponse.new({ container_instance_arns: arns }, nil)
    ]
    
    result = resources.container_arns
    
    assert_equal 1, result.size
    assert_equal arns, result
  end
  
  test "container_arns handles multiple page responses" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock multi-page response
    page1 = ["arn:aws:ecs:us-east-1:123456789012:container-instance/cluster/abc123"]
    page2 = ["arn:aws:ecs:us-east-1:123456789012:container-instance/cluster/def456"]
    
    resources.mock_ecs_client = MockEcsClient.new
    resources.mock_ecs_client.responses = [
      MockEcsResponse.new({ container_instance_arns: page1 }, "token-1"),
      MockEcsResponse.new({ container_instance_arns: page2 }, nil)
    ]
    
    result = resources.container_arns
    
    assert_equal 2, result.size
    assert_equal page1 + page2, result
  end
  
  test "container_arns returns empty array when cluster_arn is blank" do
    resources = TestableResources.new(nil)
    
    result = resources.container_arns
    
    assert_equal [], result
  end
  
  test "service_arns handles empty pages in pagination" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock response with empty pages
    page1 = []
    page2 = ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-1"]
    page3 = []
    
    resources.mock_ecs_client = MockEcsClient.new
    resources.mock_ecs_client.responses = [
      MockEcsResponse.new({ service_arns: page1 }, "token-1"),
      MockEcsResponse.new({ service_arns: page2 }, "token-2"),
      MockEcsResponse.new({ service_arns: page3 }, nil)
    ]
    
    result = resources.service_arns
    
    assert_equal 1, result.size
    assert_equal page2, result
  end
  
  test "service_arns propagates errors from ECS client" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock client that raises an error
    mock_client = MockEcsClient.new
    def mock_client.list_services(params)
      raise StandardError, "AWS API Error"
    end
    
    resources.mock_ecs_client = mock_client
    
    assert_raises(StandardError) do
      resources.service_arns
    end
  end
  
  test "container_arns propagates errors from ECS client" do
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test"
    resources = TestableResources.new(cluster_arn)
    
    # Mock client that raises an error
    mock_client = MockEcsClient.new
    def mock_client.list_container_instances(params)
      raise StandardError, "AWS API Error"
    end
    
    resources.mock_ecs_client = mock_client
    
    assert_raises(StandardError) do
      resources.container_arns
    end
  end
end
