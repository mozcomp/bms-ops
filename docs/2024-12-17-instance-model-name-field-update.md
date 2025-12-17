# Instance Model Name Field Update

**Date:** December 17, 2024  
**Task:** Update tests to support Instance model name field addition

## Task Overview

Updated all test files to support the newly added `name` field in the Instance model. The Instance model was modified to include a required `name` field with uniqueness validation, and all existing tests needed to be updated to provide this field when creating Instance objects.

## Key Changes

### Files Modified

1. **test/properties/instance_properties_test.rb**
   - Updated all `Instance.create!` and `Instance.new` calls to include `name: generate_instance_name`
   - Fixed 10 property-based tests that were failing due to missing name field
   - All property tests now pass with proper name field validation

2. **test/properties/cross_model_properties_test.rb**
   - Updated Instance creation in JSON round-trip test to include name field
   - Ensures cross-model property tests continue to pass

3. **test/controllers/instances_controller_test.rb**
   - Updated POST request parameters in controller tests to include name field
   - Fixed create action tests that were failing due to validation errors
   - Updated show test assertion to match actual view content (instance name vs tenant name)
   - All 18 controller tests now pass

### Technical Decisions

- **Name Generation**: Used existing `generate_instance_name` helper method from `property_test_helper.rb` for consistent test data
- **Unique Names**: Each test creates instances with unique names to avoid validation conflicts
- **Fixture Compatibility**: Verified that existing fixtures already included the name field
- **Controller Parameters**: Confirmed that `InstancesController` already included `:name` in strong parameters

### Testing

- **Property Tests**: All 44 property tests pass (10 instance-specific + 34 cross-model)
- **Model Tests**: All 36 instance model tests pass
- **Controller Tests**: All 18 instance controller tests pass
- **Overall Test Suite**: 345 tests pass with 0 failures

### Validation Verification

Confirmed that Instance model validation works correctly:
- ✅ Instances without name are rejected with "can't be blank" error
- ✅ Instances with valid names are accepted
- ✅ Duplicate names are rejected with custom error message
- ✅ Name field is properly included in controller strong parameters

## Next Steps

The Instance model name field integration is now complete and all tests are passing. The model is ready for continued development with proper name field validation and testing coverage.