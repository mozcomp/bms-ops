require "test_helper"

class AwsServiceTest < ActiveSupport::TestCase
  class TestClass
    include AwsService
  end

  setup do
    @service = TestClass.new
    @original_access_key = ENV["AWS_ACCESS_KEY_ID"]
    @original_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
  end

  teardown do
    ENV["AWS_ACCESS_KEY_ID"] = @original_access_key
    ENV["AWS_SECRET_ACCESS_KEY"] = @original_secret_key
  end

  test "s3 client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.s3
      assert_not_nil client
    end
  end

  test "ec2 client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.ec2
      assert_not_nil client
    end
  end

  test "ecs client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.ecs
      assert_not_nil client
    end
  end

  test "elb client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.elb
      assert_not_nil client
    end
  end

  test "ecr client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.ecr
      assert_not_nil client
    end
  end

  test "cloudwatchlogs client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.cloudwatchlogs
      assert_not_nil client
    end
  end

  test "route53 client is created successfully with valid credentials" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    assert_nothing_raised do
      client = @service.route53
      assert_not_nil client
    end
  end

  test "raises CredentialsError when AWS_ACCESS_KEY_ID is missing" do
    ENV["AWS_ACCESS_KEY_ID"] = nil
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    error = assert_raises(AwsService::CredentialsError) do
      @service.s3
    end

    assert_match(/AWS credentials are not configured/, error.message)
  end

  test "raises CredentialsError when AWS_SECRET_ACCESS_KEY is missing" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = nil

    error = assert_raises(AwsService::CredentialsError) do
      @service.ec2
    end

    assert_match(/AWS credentials are not configured/, error.message)
  end

  test "raises CredentialsError when both credentials are missing" do
    ENV["AWS_ACCESS_KEY_ID"] = nil
    ENV["AWS_SECRET_ACCESS_KEY"] = nil

    error = assert_raises(AwsService::CredentialsError) do
      @service.ecs
    end

    assert_match(/AWS credentials are not configured/, error.message)
  end

  test "clients are memoized and reused" do
    ENV["AWS_ACCESS_KEY_ID"] = "test_access_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret_key"

    client1 = @service.s3
    client2 = @service.s3

    assert_same client1, client2
  end
end
