# Property-Based Testing Guide

This directory contains property-based tests for the BMS Ops Infrastructure Management System. Property-based testing verifies that universal properties hold across all valid inputs, providing stronger correctness guarantees than example-based unit tests.

## Framework

We use the [Rantly](https://github.com/rantly-rb/rantly) gem for property-based testing in Ruby. Rantly provides:
- Random data generation
- Configurable iteration counts
- Shrinking support for minimal counterexamples

## Test Structure

Property-based tests should follow this structure:

```ruby
require "test_helper"

class MyPropertyTest < ActiveSupport::TestCase
  # Feature: infrastructure-management, Property N: [property description]
  test "property description" do
    # Run property test with minimum 100 iterations (as per design doc)
    100.times do
      # Generate random test data using helper methods
      data = generate_random_data
      
      # Perform operation
      result = perform_operation(data)
      
      # Assert property holds
      assert property_holds?(result), "Property should hold for all inputs"
    end
  end
end
```

## Available Generators

The `PropertyTestHelper` module provides generators for all common data types:

### Tenant Generators
- `generate_tenant_code` - Random alphanumeric code (3-10 chars)
- `generate_tenant_name` - Random tenant name
- `generate_subdomain` - Random subdomain
- `generate_tenant_configuration` - Complete tenant configuration JSON

### App Generators
- `generate_app_name` - Random application name
- `generate_repo_owner` - Random repository owner
- `generate_repo_name` - Random repository name
- `generate_repo_platform` - Random platform (GitHub/GitLab/Bitbucket)
- `generate_repository_url(format:)` - Random repository URL in various formats

### Service Generators
- `generate_service_name` - Random service name
- `generate_image_name` - Random Docker image name
- `generate_registry` - Random Docker registry
- `generate_version` - Random semantic version
- `generate_service_environment` - Service environment variables JSON

### Database Generators
- `generate_database_name` - Random database name
- `generate_database_connection` - Database connection JSON

### Instance Generators
- `generate_environment` - Random environment (production/staging/development)
- `generate_virtual_host(environment:, subdomain:)` - Random virtual host
- `generate_instance_env_vars` - Instance environment variables JSON

### Error Case Generators
- `generate_invalid_json` - Invalid JSON strings for error handling tests
- `generate_invalid_repository_url` - Invalid repository URLs

### Helper Methods
- `create_random_tenant` - Create and persist a random tenant
- `create_random_app` - Create and persist a random app
- `create_random_service` - Create and persist a random service
- `create_random_database` - Create and persist a random database
- `create_random_instance(tenant:, app:, service:)` - Create and persist a random instance

## Writing Property Tests

### Example 1: Round-trip Property

```ruby
# Feature: infrastructure-management, Property 2: Configuration JSON round-trip
test "configuration JSON round-trip preserves data" do
  100.times do
    # Generate random configuration
    original_config = generate_tenant_configuration
    
    # Create tenant with configuration
    tenant = Tenant.create!(
      code: generate_tenant_code,
      name: generate_tenant_name,
      configuration: original_config
    )
    
    # Retrieve and compare
    retrieved_config = tenant.reload.configuration
    assert_equal original_config.stringify_keys, retrieved_config,
      "Configuration should round-trip through database"
  end
end
```

### Example 2: Invariant Property

```ruby
# Feature: infrastructure-management, Property 4: Deletion removes records
test "deletion removes records from database" do
  100.times do
    # Create random tenant
    tenant = create_random_tenant
    tenant_id = tenant.id
    
    # Delete tenant
    tenant.destroy!
    
    # Verify it's gone
    assert_nil Tenant.find_by(id: tenant_id),
      "Deleted tenant should not exist in database"
  end
end
```

### Example 3: Validation Property

```ruby
# Feature: infrastructure-management, Property 5: Uniqueness validation
test "duplicate codes are rejected" do
  100.times do
    # Create first tenant
    code = generate_tenant_code
    Tenant.create!(code: code, name: generate_tenant_name)
    
    # Attempt to create duplicate
    duplicate = Tenant.new(code: code, name: generate_tenant_name)
    
    # Should fail validation
    assert_not duplicate.valid?,
      "Duplicate tenant code should fail validation"
    assert_includes duplicate.errors[:code], "has already been taken"
  end
end
```

## Running Property Tests

Run all property tests:
```bash
bin/rails test test/properties/
```

Run a specific property test file:
```bash
bin/rails test test/properties/tenant_properties_test.rb
```

Run a specific property test:
```bash
bin/rails test test/properties/tenant_properties_test.rb:24
```

## Best Practices

1. **Minimum 100 iterations**: Each property test should run at least 100 iterations as specified in the design document.

2. **Tag with property number**: Always include a comment linking to the design document property:
   ```ruby
   # Feature: infrastructure-management, Property N: [property description]
   ```

3. **Clean up test data**: Use transactions or explicit cleanup to avoid test pollution:
   ```ruby
   test "my property" do
     100.times do
       # Test code here
     end
   end
   # ActiveSupport::TestCase automatically wraps tests in transactions
   ```

4. **Test one property per test**: Each test should verify a single property for clarity.

5. **Use descriptive assertions**: Include helpful messages in assertions to aid debugging.

6. **Generate valid inputs**: Ensure generators produce data within the valid input domain.

7. **Test error cases separately**: Use separate tests for error handling properties.

## Debugging Failed Properties

When a property test fails:

1. **Check the counterexample**: Rantly will show the input that caused the failure
2. **Verify the generator**: Ensure the generator produces valid inputs
3. **Check the property**: Verify the property correctly captures the requirement
4. **Isolate the issue**: Create a unit test with the specific failing input
5. **Fix and re-run**: Fix the code or test and verify with 100+ iterations

## Integration with CI/CD

Property tests run as part of the standard test suite:
```bash
bin/rails test
```

They provide additional confidence that the system behaves correctly across a wide range of inputs, complementing example-based unit tests.
