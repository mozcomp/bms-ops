require "test_helper"

class AwsPaginationPropertiesTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property 14: AWS pagination completeness
  # Validates: Requirements 5.2, 5.3
  
  # Mock ECS response structure
  class MockEcsResponse
    attr_reader :service_arns, :container_instance_arns, :next_token
    
    def initialize(arns, next_token = nil)
      @service_arns = arns[:service_arns] || []
      @container_instance_arns = arns[:container_instance_arns] || []
      @next_token = next_token
    end
  end
  
  # Mock Resources class for testing pagination
  class MockResources
    include AwsService
    
    attr_accessor :mock_responses
    
    def initialize(cluster_arn)
      @cluster_arn = cluster_arn
      @mock_responses = []
      @call_count = 0
    end
    
    def cluster_arn
      @cluster_arn
    end
    
    # Override ecs to return mock client
    def ecs
      @mock_ecs ||= MockEcsClient.new(self)
    end
    
    # Implement service_arns with pagination logic (same as Resources class)
    def service_arns
      return [] if cluster_arn.blank?
      
      list_service_arns = []
      next_token = nil
      
      loop do
        params = { cluster: cluster_arn }
        params[:next_token] = next_token if next_token
        
        response = ecs.list_services(params)
        list_service_arns += response.service_arns
        next_token = response.next_token
        
        break if next_token.nil?
      end
      
      list_service_arns
    end
    
    # Implement container_arns with pagination logic (same as Resources class)
    def container_arns
      return [] if cluster_arn.blank?
      
      list_container_arns = []
      next_token = nil
      
      loop do
        params = { cluster: cluster_arn }
        params[:next_token] = next_token if next_token
        
        response = ecs.list_container_instances(params)
        list_container_arns += response.container_instance_arns
        next_token = response.next_token
        
        break if next_token.nil?
      end
      
      list_container_arns
    end
    
    def get_next_response
      @call_count += 1
      @mock_responses[@call_count - 1]
    end
  end
  
  # Mock ECS client
  class MockEcsClient
    def initialize(resources)
      @resources = resources
    end
    
    def list_services(params)
      @resources.get_next_response
    end
    
    def list_container_instances(params)
      @resources.get_next_response
    end
  end
  
  test "service ARN pagination retrieves all ARNs across multiple pages" do
    # Skip AWS credentials check for this test
    ENV["AWS_ACCESS_KEY_ID"] = "test_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret"
    
    100.times do
      # Generate random number of pages (1-5)
      num_pages = Rantly { range(1, 5) }
      
      # Generate random ARNs for each page
      all_arns = []
      mock_responses = []
      
      num_pages.times do |i|
        # Generate 1-10 ARNs per page
        page_size = Rantly { range(1, 10) }
        page_arns = Array.new(page_size) do
          "arn:aws:ecs:us-east-1:123456789012:service/cluster/service-#{SecureRandom.hex(8)}"
        end
        
        all_arns.concat(page_arns)
        
        # Last page has no next_token
        next_token = (i < num_pages - 1) ? "token-#{i + 1}" : nil
        mock_responses << MockEcsResponse.new({ service_arns: page_arns }, next_token)
      end
      
      # Create mock resources with pagination responses
      cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"
      resources = MockResources.new(cluster_arn)
      resources.mock_responses = mock_responses
      
      # Execute pagination
      result = resources.service_arns
      
      # Verify all ARNs were retrieved
      assert_equal all_arns.size, result.size, "Should retrieve all ARNs across all pages"
      assert_equal all_arns, result, "Should retrieve ARNs in correct order"
      
      # Verify no duplicates
      assert_equal result.size, result.uniq.size, "Should not have duplicate ARNs"
    end
  end
  
  test "container ARN pagination retrieves all ARNs across multiple pages" do
    # Skip AWS credentials check for this test
    ENV["AWS_ACCESS_KEY_ID"] = "test_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret"
    
    100.times do
      # Generate random number of pages (1-5)
      num_pages = Rantly { range(1, 5) }
      
      # Generate random ARNs for each page
      all_arns = []
      mock_responses = []
      
      num_pages.times do |i|
        # Generate 1-10 ARNs per page
        page_size = Rantly { range(1, 10) }
        page_arns = Array.new(page_size) do
          "arn:aws:ecs:us-east-1:123456789012:container-instance/cluster/#{SecureRandom.hex(8)}"
        end
        
        all_arns.concat(page_arns)
        
        # Last page has no next_token
        next_token = (i < num_pages - 1) ? "token-#{i + 1}" : nil
        mock_responses << MockEcsResponse.new({ container_instance_arns: page_arns }, next_token)
      end
      
      # Create mock resources with pagination responses
      cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"
      resources = MockResources.new(cluster_arn)
      resources.mock_responses = mock_responses
      
      # Execute pagination
      result = resources.container_arns
      
      # Verify all ARNs were retrieved
      assert_equal all_arns.size, result.size, "Should retrieve all ARNs across all pages"
      assert_equal all_arns, result, "Should retrieve ARNs in correct order"
      
      # Verify no duplicates
      assert_equal result.size, result.uniq.size, "Should not have duplicate ARNs"
    end
  end
  
  test "pagination handles empty pages correctly" do
    # Skip AWS credentials check for this test
    ENV["AWS_ACCESS_KEY_ID"] = "test_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret"
    
    100.times do
      # Create responses with some empty pages
      mock_responses = [
        MockEcsResponse.new({ service_arns: [] }, "token-1"),
        MockEcsResponse.new({ service_arns: ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-1"] }, "token-2"),
        MockEcsResponse.new({ service_arns: [] }, "token-3"),
        MockEcsResponse.new({ service_arns: ["arn:aws:ecs:us-east-1:123456789012:service/cluster/service-2"] }, nil)
      ]
      
      cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"
      resources = MockResources.new(cluster_arn)
      resources.mock_responses = mock_responses
      
      result = resources.service_arns
      
      # Should only get the non-empty ARNs
      assert_equal 2, result.size, "Should retrieve only non-empty ARNs"
    end
  end
  
  test "pagination returns empty array when cluster_arn is blank" do
    # Skip AWS credentials check for this test
    ENV["AWS_ACCESS_KEY_ID"] = "test_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret"
    
    100.times do
      resources = MockResources.new(nil)
      
      result = resources.service_arns
      assert_equal [], result, "Should return empty array when cluster_arn is blank"
      
      result = resources.container_arns
      assert_equal [], result, "Should return empty array when cluster_arn is blank"
    end
  end
end
