# Implementation Plan

- [ ] 1. Set up property-based testing framework
  - Install and configure the `rantly` gem for property-based testing
  - Create test helper utilities for generating random test data
  - Set up test directory structure for property tests
  - _Requirements: All properties_

- [ ] 2. Implement and test Tenant model enhancements
- [ ] 2.1 Enhance Tenant model with robust JSON handling
  - Ensure configuration JSON field has proper default initialization
  - Add comprehensive virtual attribute methods for configuration access
  - Implement URL computation logic
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 2.2 Write property test for tenant creation with defaults
  - **Property 1: Tenant creation with defaults**
  - **Validates: Requirements 1.1**

- [ ] 2.3 Write property test for tenant computed fields
  - **Property 3: Tenant computed fields presence**
  - **Validates: Requirements 1.3**

- [ ] 2.4 Write unit tests for tenant model
  - Test validation rules (presence, uniqueness)
  - Test virtual attribute getters and setters
  - Test URL computation edge cases
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 3. Implement and test App model enhancements
- [ ] 3.1 Enhance App model repository parsing logic
  - Refine repository URL validation regex
  - Implement robust parsing for HTTPS, SSH, and short formats
  - Add platform detection logic
  - Add URL conversion methods
  - _Requirements: 2.1, 2.2, 2.3, 2.5, 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 3.2 Write property test for app creation and persistence
  - **Property 6: App creation and persistence**
  - **Validates: Requirements 2.1**

- [ ] 3.3 Write property test for repository URL format acceptance
  - **Property 7: Repository URL format acceptance**
  - **Validates: Requirements 2.2**

- [ ] 3.4 Write property test for app computed fields
  - **Property 8: App computed fields correctness**
  - **Validates: Requirements 2.3**

- [ ] 3.5 Write property test for invalid repository rejection
  - **Property 9: Invalid repository rejection**
  - **Validates: Requirements 2.5, 6.4**

- [ ] 3.6 Write property test for repository URL parsing
  - **Property 18: Repository URL parsing completeness**
  - **Validates: Requirements 8.1, 8.2, 8.3**

- [ ] 3.7 Write property test for repository platform detection
  - **Property 19: Repository platform detection**
  - **Validates: Requirements 8.4**

- [ ] 3.8 Write property test for SSH to HTTPS conversion
  - **Property 20: SSH to HTTPS URL conversion**
  - **Validates: Requirements 8.5**

- [ ] 3.9 Write unit tests for app model
  - Test repository parsing edge cases
  - Test platform detection for various URLs
  - Test URL conversion logic
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 4. Implement and test Service model enhancements
- [ ] 4.1 Enhance Service model JSON handling
  - Ensure all JSON fields initialize to empty objects
  - Implement robust JSON parsing with error handling
  - Add full_image computation logic
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 4.2 Write property test for service JSON initialization
  - **Property 10: Service JSON field initialization**
  - **Validates: Requirements 3.1, 4.1**

- [ ] 4.3 Write property test for full image computation
  - **Property 11: Full image reference computation**
  - **Validates: Requirements 3.3**

- [ ] 4.4 Write property test for JSON parsing error handling
  - **Property 12: JSON parsing error handling**
  - **Validates: Requirements 3.4, 6.3**

- [ ] 4.5 Write unit tests for service model
  - Test JSON field initialization
  - Test full_image computation with various inputs
  - Test JSON parsing error scenarios
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 5. Implement and test Database model enhancements
- [ ] 5.1 Enhance Database model connection handling
  - Ensure connection JSON field initializes properly
  - Implement connection detail extraction methods
  - Add connection string formatting logic
  - Add default value handling for missing connection data
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 5.2 Write property test for database connection string format
  - **Property 13: Database connection string format**
  - **Validates: Requirements 4.3**

- [ ] 5.3 Write unit tests for database model
  - Test connection JSON parsing
  - Test connection string formatting
  - Test default value handling
  - Test edge cases (nil, empty connection)
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 6. Implement and test Instance model
- [ ] 6.1 Create Instance model with associations
  - Generate migration for instances table with foreign keys
  - Implement Instance model with belongs_to associations
  - Add validations for required fields and environment enum
  - Add uniqueness constraint on tenant_id, app_id, environment
  - Implement computed methods (full_url, environment_label)
  - _Requirements: 9.1, 9.2, 9.3, 9.6, 9.7_

- [ ] 6.2 Add associations to related models
  - Add has_many :instances to Tenant model
  - Add has_many :instances to App model
  - Add has_many :instances to Service model
  - _Requirements: 9.1, 9.4, 9.5, 9.6_

- [ ] 6.3 Write property test for instance creation
  - **Property 21: Instance creation with associations**
  - **Validates: Requirements 9.1**

- [ ] 6.4 Write property test for environment validation
  - **Property 22: Environment validation**
  - **Validates: Requirements 9.2**

- [ ] 6.5 Write property test for instance computed fields
  - **Property 23: Instance computed fields**
  - **Validates: Requirements 9.3**

- [ ] 6.6 Write property test for instance querying by tenant
  - **Property 24: Instance querying by tenant**
  - **Validates: Requirements 9.4**

- [ ] 6.7 Write property test for instance querying by environment
  - **Property 25: Instance querying by environment**
  - **Validates: Requirements 9.5**

- [ ] 6.8 Write property test for instance deletion
  - **Property 26: Instance deletion preserves associations**
  - **Validates: Requirements 9.6**

- [ ] 6.9 Write property test for instance uniqueness
  - **Property 27: Instance uniqueness per tenant-app-environment**
  - **Validates: Requirements 9.7**

- [ ] 6.10 Write unit tests for instance model
  - Test association setup
  - Test environment validation
  - Test uniqueness constraint
  - Test computed methods
  - Test scopes for querying by tenant and environment
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_

- [ ] 7. Implement cross-model property tests
- [ ] 7.1 Write property test for JSON round-trip
  - **Property 2: Configuration JSON round-trip**
  - **Validates: Requirements 1.2, 3.2, 4.2**

- [ ] 7.2 Write property test for deletion
  - **Property 4: Deletion removes records**
  - **Validates: Requirements 1.4**

- [ ] 7.3 Write property test for uniqueness validation
  - **Property 5: Uniqueness validation**
  - **Validates: Requirements 1.5, 2.4, 3.5, 4.5, 6.2**

- [ ] 7.4 Write property test for required field validation
  - **Property 15: Required field validation**
  - **Validates: Requirements 6.1**

- [ ] 7.5 Write property test for update validation
  - **Property 16: Update validation preserves state**
  - **Validates: Requirements 6.5**

- [ ] 8. Checkpoint - Ensure all model tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Implement InstancesController
- [ ] 9.1 Create InstancesController with CRUD actions
  - Implement index, show, new, create, edit, update, destroy actions
  - Add strong parameters for instance attributes
  - Implement filtering by tenant and environment
  - Add proper error handling and flash messages
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_

- [ ] 9.2 Create instance views
  - Create index view with filtering options
  - Create show view displaying all associations
  - Create form partial with tenant, app, service, and environment selects
  - Add proper error display
  - _Requirements: 9.1, 9.2, 9.3_

- [ ] 9.3 Add instances routes
  - Add resources :instances to routes.rb
  - _Requirements: 9.1_

- [ ] 9.4 Write controller tests for instances
  - Test CRUD operations
  - Test filtering by tenant and environment
  - Test validation error handling
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_

- [ ] 10. Enhance controller implementations
- [ ] 10.1 Review and enhance TenantsController
  - Verify strong parameters include all configuration fields
  - Ensure proper error handling and flash messages
  - Verify redirect behavior
  - Add link to view tenant instances
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 10.2 Review and enhance AppsController
  - Verify strong parameters
  - Ensure proper validation error handling
  - Verify index ordering
  - Add link to view app instances
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 7.2_

- [ ] 10.3 Review and enhance ServicesController
  - Verify strong parameters include JSON fields
  - Ensure proper error handling
  - Verify index ordering
  - Add link to view service instances
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 7.3_

- [ ] 10.4 Review and enhance DatabasesController
  - Verify strong parameters
  - Ensure proper error handling
  - Verify index ordering
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 7.4_

- [ ] 10.5 Write property test for index ordering
  - **Property 17: Index ordering consistency**
  - **Validates: Requirements 7.1, 7.2, 7.3, 7.4**

- [ ] 10.6 Write controller integration tests
  - Test full CRUD cycles for each controller
  - Test form submissions with valid and invalid data
  - Test flash messages and redirects
  - _Requirements: 1.1-1.5, 2.1-2.5, 3.1-3.5, 4.1-4.5, 9.1-9.7_

- [ ] 11. Enhance AWS integration services
- [ ] 11.1 Review and enhance AwsService module
  - Verify all AWS clients are properly initialized
  - Add error handling for missing credentials
  - Add logging for AWS operations
  - _Requirements: 5.1, 5.4_

- [ ] 11.2 Enhance Resources class with pagination
  - Implement complete pagination for service ARNs
  - Implement complete pagination for container ARNs
  - Add error handling for missing cluster configuration
  - Add logging for resource discovery
  - _Requirements: 5.2, 5.3, 5.5_

- [ ] 11.3 Write unit tests for AWS service initialization
  - Test client creation for all AWS services
  - Test error handling for missing credentials
  - _Requirements: 5.1, 5.4_

- [ ] 11.4 Write property test for AWS pagination
  - **Property 14: AWS pagination completeness**
  - **Validates: Requirements 5.2, 5.3**

- [ ] 11.5 Write unit tests for Resources class
  - Test pagination logic with mocked AWS responses
  - Test error handling for missing cluster name
  - Test service and container discovery
  - _Requirements: 5.2, 5.3, 5.5_

- [ ] 12. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Enhance view layer
- [ ] 13.1 Review tenant views
  - Verify form includes all configuration fields
  - Verify show page displays all computed fields
  - Add section showing associated instances
  - Verify error message display
  - _Requirements: 1.1, 1.2, 1.3, 9.4_

- [ ] 13.2 Review app views
  - Verify repository URL format hints
  - Verify computed fields display
  - Add section showing associated instances
  - Verify error message display
  - _Requirements: 2.1, 2.2, 2.3, 9.4_

- [ ] 13.3 Review service views
  - Verify JSON field editing interface
  - Verify full_image display
  - Add section showing associated instances
  - Verify error message display
  - _Requirements: 3.1, 3.2, 3.3, 9.4_

- [ ] 13.4 Review database views
  - Verify connection JSON editing
  - Verify connection string display
  - Verify error message display
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 13.5 Review instance views
  - Verify form has proper select dropdowns for associations
  - Verify environment dropdown has only valid values
  - Verify show page displays all association details
  - Verify filtering works on index page
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 13.6 Review index views for all resources
  - Verify ordering by created_at descending
  - Verify empty state messages
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 14. Add comprehensive error handling
- [ ] 14.1 Add global error handling for AWS operations
  - Implement rescue blocks for AWS SDK errors
  - Add user-friendly error messages
  - Add error logging
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 14.2 Add validation error handling improvements
  - Ensure all validation errors display field-specific messages
  - Verify error styling is consistent
  - Test instance uniqueness constraint error messages
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 9.7_

- [ ] 15. Update dashboard and navigation
- [ ] 15.1 Add instances to dashboard
  - Add instances count and recent instances to dashboard
  - Add navigation link to instances
  - _Requirements: 9.1_

- [ ] 15.2 Update navigation menu
  - Add Instances link to main navigation
  - Ensure all resource links are present
  - _Requirements: 9.1_

- [ ] 16. Final checkpoint - Complete test suite
  - Ensure all tests pass, ask the user if questions arise.
