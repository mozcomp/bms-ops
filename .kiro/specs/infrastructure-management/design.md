# Design Document

## Overview

The BMS Ops Infrastructure Management System is a Rails-based web application that provides a centralized interface for managing multi-tenant AWS infrastructure. The system follows a traditional MVC architecture with ActiveRecord models, RESTful controllers, and Tailwind-styled views. The application manages five core entities: Tenants, Apps, Services, Databases, and Instances, each with CRUD operations and specialized business logic for AWS integration.

Instances are the central connecting entity that links Tenants (clients), Apps (codebases), Services (ECS services), and Environments (production/staging/development) together, representing a specific deployment configuration with a virtual host.

The system integrates with AWS services (ECS, S3, EC2, ECR, ELB, CloudWatch Logs, Route53) to provide real-time infrastructure management capabilities. Data is persisted in SQLite (development) and MySQL (production) with JSON fields for flexible configuration storage and foreign keys for maintaining referential integrity between entities.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Web Browser (UI)                         │
│                   Tailwind CSS + Stimulus                    │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/HTTPS
┌────────────────────────▼────────────────────────────────────┐
│                   Rails Application                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Controllers Layer                        │   │
│  │  TenantsController │ AppsController │ ServicesController│ │
│  │  DatabasesController │ InstancesController            │   │
│  │  DashboardController                                  │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │              Models Layer                             │   │
│  │  Tenant │ App │ Service │ Database │ Instance        │   │
│  │  (ActiveRecord with JSON fields & associations)      │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │           Services Layer                              │   │
│  │  AwsService │ Resources │ Resource::* classes        │   │
│  └──────────────────────┬───────────────────────────────┘   │
└─────────────────────────┼────────────────────────────────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
┌────────▼────────┐  ┌───▼────────┐  ┌───▼──────────┐
│ SQLite/MySQL DB │  │  AWS ECS   │  │  AWS S3/EC2  │
│  (Data Store)   │  │ (Services) │  │  (Resources) │
└─────────────────┘  └────────────┘  └──────────────┘
```

### Component Responsibilities

- **Controllers**: Handle HTTP requests, parameter validation, and response rendering
- **Models**: Encapsulate business logic, validations, data persistence, and associations between entities
- **Services**: Provide AWS integration and complex resource management
- **Views**: Render HTML with Tailwind CSS styling and Stimulus controllers for interactivity

### Key Relationships

- **Instance** belongs to **Tenant**, **App**, and **Service**
- **Tenant** has many **Instances**
- **App** has many **Instances**
- **Service** has many **Instances**
- Each Instance represents a unique combination of Tenant + App + Environment

## Components and Interfaces

### Core Models

#### Tenant Model
```ruby
class Tenant < ApplicationRecord
  # Attributes: code, name, configuration (JSON)
  # Virtual attributes: subdomain, database, service_name, ses_region, s3_bucket
  
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  
  # Methods
  def url # Returns computed HTTPS URL
  def subdomain # Extracts from configuration or defaults to code
  def database # Extracts from configuration or defaults to bms_{code}_production
end
```

#### App Model
```ruby
class App < ApplicationRecord
  # Attributes: name, repository
  
  validates :name, presence: true, uniqueness: true
  validates :repository, presence: true, format: { with: REPO_REGEX }
  
  # Methods
  def repository_name # Returns owner/repo format
  def repository_owner # Extracts owner from URL
  def repository_short_name # Returns repo name without owner
  def repository_platform # Returns GitHub, GitLab, or Bitbucket
  def repository_url # Returns clean HTTPS URL
end
```

#### Service Model
```ruby
class Service < ApplicationRecord
  # Attributes: name, image, registry, version, environment (JSON),
  #             service_definition (JSON), task_definitions (JSON)
  
  validates :name, presence: true, uniqueness: true
  validates :image, presence: true
  
  # Methods
  def full_image # Returns registry/image:version format
  def status # Returns service status (placeholder for AWS integration)
end
```

#### Database Model
```ruby
class Database < ApplicationRecord
  # Attributes: name, connection (JSON), schema_version
  
  validates :name, presence: true, uniqueness: true
  
  # Methods
  def host, port, database_name, username, adapter # Extract from connection JSON
  def connection_string # Returns formatted connection string
  def status # Returns configuration status
end
```

#### Instance Model
```ruby
class Instance < ApplicationRecord
  # Attributes: tenant_id, app_id, service_id, environment, virtual_host, env_vars (JSON)
  
  belongs_to :tenant
  belongs_to :app
  belongs_to :service
  
  validates :tenant_id, presence: true
  validates :app_id, presence: true
  validates :service_id, presence: true
  validates :environment, presence: true, inclusion: { in: %w[production staging development] }
  validates :virtual_host, presence: true
  
  before_validation :set_default_virtual_host, on: :create
  before_save :ensure_env_vars
  
  # Virtual attributes for JSON field editing
  def env_vars_json
    env_vars.to_json if env_vars.present?
  end
  
  def env_vars_json=(value)
    self.env_vars = value.present? ? JSON.parse(value) : {}
  rescue JSON::ParserError
    self.env_vars = {}
  end
  
  # Methods
  def environment_label # Returns human-readable environment name
  def full_url # Returns complete URL with protocol
  
  private
  
  def set_default_virtual_host
    return if virtual_host.present?
    return unless tenant.present?
    
    subdomain = tenant.subdomain
    subdomain = "#{environment}-#{subdomain}" unless environment == 'production'
    self.virtual_host = "#{subdomain}.bmserp.com"
  end
  
  def ensure_env_vars
    self.env_vars ||= {}
  end
end
```

#### Instance Model
```ruby
class Instance < ApplicationRecord
  # Attributes: tenant_id, app_id, service_id, environment, virtual_host
  
  belongs_to :tenant
  belongs_to :app
  belongs_to :service
  
  validates :tenant_id, presence: true
  validates :app_id, presence: true
  validates :service_id, presence: true
  validates :environment, presence: true, inclusion: { in: %w[production staging development] }
  validates :tenant_id, uniqueness: { scope: [:app_id, :environment] }
  
  # Methods
  def full_url # Returns computed URL based on virtual_host or tenant subdomain
  def environment_label # Returns human-readable environment name
end
```

### Controllers

All controllers follow RESTful conventions with standard actions:
- `index`: List all records (ordered by created_at DESC)
- `show`: Display single record
- `new`: Render creation form
- `create`: Persist new record
- `edit`: Render edit form
- `update`: Persist changes
- `destroy`: Delete record

Controllers use strong parameters for mass assignment protection and handle validation errors by re-rendering forms with error messages.

#### InstancesController
The InstancesController manages the relationships between Tenants, Apps, Services, and Environments:
- Uses eager loading (`includes`) to efficiently load associations
- Provides filtering capabilities by tenant_id and service_id
- Validates environment values through the model
- Handles virtual_host generation automatically via model callbacks
- Handles env_vars JSON parsing through virtual attributes
- Strong parameters: `tenant_id`, `app_id`, `service_id`, `environment`, `virtual_host` (optional), `env_vars_json` (optional)

### AWS Integration Services

#### AwsService Module
Provides authenticated AWS SDK clients for:
- S3 (storage)
- EC2 (compute instances)
- ECS (container orchestration)
- ELB (load balancing)
- ECR (container registry)
- CloudWatch Logs (logging)
- Route53 (DNS)

#### Resources Class
Orchestrates AWS resource discovery and management:
- Queries ECS for cluster, service, and container information
- Loads service definitions from filesystem
- Manages images and DNS zones
- Provides pagination support for large result sets

### View Layer

Views use:
- Tailwind CSS for styling with dark mode support
- Stimulus controllers for interactive behavior
- Partial forms for DRY form rendering
- Flash messages for user feedback
- Icon helpers for consistent iconography

#### Instance Views
Instance views provide a comprehensive interface for managing tenant-app-service relationships:
- **Index**: Table view with columns for tenant, app, service, environment, and virtual_host
  - Environment badges with color coding (production: green, staging: yellow, development: blue)
  - Filtering by tenant or service
  - Links to associated records
- **Show**: Detailed view displaying all association information
  - Tenant details with link
  - App details with repository information
  - Service details with image information
  - Environment and virtual_host
  - Full URL display
  - Environment variables display in formatted key-value pairs
- **Form**: Select dropdowns for associations
  - Tenant select (populated from Tenant.all)
  - App select (populated from App.all)
  - Service select (populated from Service.all)
  - Environment select (production, staging, development)
  - Optional virtual_host field with auto-generation preview
  - Textarea for env_vars JSON with syntax highlighting and validation
  - Helper text showing example JSON format

## Data Models

### Database Schema

```
tenants
  - id: integer (primary key)
  - code: string (unique, not null)
  - name: string (not null)
  - configuration: json
  - created_at: datetime
  - updated_at: datetime

apps
  - id: integer (primary key)
  - name: string (unique, not null)
  - repository: string (not null)
  - created_at: datetime
  - updated_at: datetime

services
  - id: integer (primary key)
  - name: string (unique, not null)
  - image: string (not null)
  - registry: string
  - version: string
  - environment: json
  - service_definition: json
  - task_definitions: json
  - created_at: datetime
  - updated_at: datetime

databases
  - id: integer (primary key)
  - name: string (unique, not null)
  - connection: json
  - schema_version: string
  - created_at: datetime
  - updated_at: datetime

instances
  - id: integer (primary key)
  - tenant_id: integer (foreign key, not null)
  - app_id: integer (foreign key, not null)
  - service_id: integer (foreign key, not null)
  - environment: string (not null)
  - virtual_host: string (not null)
  - env_vars: json
  - created_at: datetime
  - updated_at: datetime
  - index on tenant_id
  - index on app_id
  - index on service_id
  - index on environment
  - unique index on [tenant_id, app_id, environment]
```

### JSON Field Structures

#### Tenant Configuration
```json
{
  "subdomain": "acme",
  "database": "bms_acme_production",
  "service_name": "bms-acme-service",
  "ses_region": "ap-southeast-2",
  "s3_bucket": "bms-acme-production"
}
```

#### Service Environment
```json
{
  "DATABASE_URL": "mysql2://...",
  "REDIS_URL": "redis://...",
  "RAILS_ENV": "production"
}
```

#### Database Connection
```json
{
  "host": "localhost",
  "port": 3306,
  "database": "bms_acme_production",
  "username": "postgres",
  "adapter": "mysql2"
}
```

#### Instance Environment Variables
```json
{
  "DATABASE_URL": "mysql2://user:pass@host:3306/bms_acme_production",
  "REDIS_URL": "redis://localhost:6379/0",
  "RAILS_ENV": "production",
  "SECRET_KEY_BASE": "...",
  "AWS_REGION": "ap-southeast-2",
  "S3_BUCKET": "bms-acme-production",
  "TENANT_CODE": "acme"
}
```

## Correctn
ess Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Tenant creation with defaults
*For any* valid tenant with unique code and name, creating the tenant should persist it to the database with a properly initialized empty configuration JSON object.
**Validates: Requirements 1.1**

### Property 2: Configuration JSON round-trip
*For any* valid JSON configuration data (tenant configuration, service environment/definitions, or database connection), storing the JSON and then retrieving it should return equivalent data.
**Validates: Requirements 1.2, 3.2, 4.2**

### Property 3: Tenant computed fields presence
*For any* tenant record, the view representation should contain all required fields: code, name, subdomain, database name, service name, SES region, S3 bucket, and computed URL.
**Validates: Requirements 1.3**

### Property 4: Deletion removes records
*For any* existing record (tenant, app, service, or database), deleting it should result in the record no longer existing in the database.
**Validates: Requirements 1.4**

### Property 5: Uniqueness validation
*For any* model with unique constraints (tenant code, app name, service name, database name), attempting to create a duplicate should be rejected with a validation error.
**Validates: Requirements 1.5, 2.4, 3.5, 4.5, 6.2**

### Property 6: App creation and persistence
*For any* valid app with unique name and properly formatted repository URL, creating the app should persist it to the database.
**Validates: Requirements 2.1**

### Property 7: Repository URL format acceptance
*For any* repository URL in valid HTTPS, SSH, or short format from GitHub, GitLab, or Bitbucket, the system should accept and persist the URL.
**Validates: Requirements 2.2**

### Property 8: App computed fields correctness
*For any* app record with a valid repository URL, the system should correctly compute and display repository owner, repository name, platform, and clean HTTPS URL.
**Validates: Requirements 2.3**

### Property 9: Invalid repository rejection
*For any* repository URL that does not match valid GitHub, GitLab, or Bitbucket patterns, the system should reject creation with a format validation error.
**Validates: Requirements 2.5, 6.4**

### Property 10: Service JSON field initialization
*For any* service created with only name and image, the system should initialize environment, service_definition, and task_definitions as empty JSON objects.
**Validates: Requirements 3.1, 4.1**

### Property 11: Full image reference computation
*For any* service with registry, image, and version values, the computed full_image should equal "registry/image:version" format.
**Validates: Requirements 3.3**

### Property 12: JSON parsing error handling
*For any* invalid JSON string provided to JSON fields, the system should gracefully default the field to an empty JSON object without raising an exception.
**Validates: Requirements 3.4, 6.3**

### Property 13: Database connection string format
*For any* database with connection JSON containing host, port, database, username, and adapter, the connection_string should be formatted as "adapter://username@host:port/database".
**Validates: Requirements 4.3**

### Property 14: AWS pagination completeness
*For any* ECS cluster with multiple pages of services or containers, the system should retrieve all ARNs across all pages using pagination tokens.
**Validates: Requirements 5.2, 5.3**

### Property 15: Required field validation
*For any* model record created with missing required fields, the system should reject creation and return field-specific validation errors.
**Validates: Requirements 6.1**

### Property 16: Update validation preserves state
*For any* existing record, attempting to update with invalid data should preserve the original record state and return validation errors.
**Validates: Requirements 6.5**

### Property 17: Index ordering consistency
*For any* collection of records (tenants, apps, services, or databases), the index view should display them ordered by created_at in descending order.
**Validates: Requirements 7.1, 7.2, 7.3, 7.4**

### Property 18: Repository URL parsing completeness
*For any* valid repository URL (HTTPS, SSH, or with .git suffix), the system should correctly extract owner and repository name, removing any .git suffix.
**Validates: Requirements 8.1, 8.2, 8.3**

### Property 19: Repository platform detection
*For any* repository URL containing github.com, gitlab.com, or bitbucket.org, the system should correctly identify the platform as GitHub, GitLab, or Bitbucket respectively.
**Validates: Requirements 8.4**

### Property 20: SSH to HTTPS URL conversion
*For any* repository URL in SSH format (git@host:owner/repo), converting to display URL should produce a valid HTTPS format (https://host/owner/repo).
**Validates: Requirements 8.5**

### Property 21: Instance creation with associations
*For any* valid instance with tenant, app, service, and environment, creating the instance should persist it with all associations intact.
**Validates: Requirements 9.1**

### Property 22: Environment validation
*For any* instance, the environment field should only accept the values "production", "staging", or "development", rejecting any other values.
**Validates: Requirements 9.2**

### Property 23: Instance associations query
*For any* tenant or service, querying for associated instances should return all instances linked to that tenant or service.
**Validates: Requirements 9.4, 9.5**

### Property 24: Instance deletion preserves associations
*For any* instance, deleting it should remove only the instance record while preserving the associated tenant, app, and service records.
**Validates: Requirements 9.6**

### Property 25: Virtual host generation
*For any* instance created without a virtual_host, the system should generate a default virtual host based on tenant subdomain and environment (prefixing with environment for non-production).
**Validates: Requirements 9.7**

### Property 26: Instance env_vars JSON round-trip
*For any* valid JSON environment variables data, storing it in an instance's env_vars field and then retrieving it should return equivalent data.
**Validates: Requirements 9.8**

### Property 27: Instance env_vars JSON parsing error handling
*For any* invalid JSON string provided to the env_vars field, the system should gracefully default the field to an empty JSON object without raising an exception.
**Validates: Requirements 9.9**

### Property 28: Instance env_vars initialization
*For any* instance created without env_vars, the system should initialize the env_vars field as an empty JSON object.
**Validates: Requirements 9.8**

### Property 21: Instance creation with associations
*For any* valid instance with tenant, app, service, and environment, creating the instance should persist it with all associations intact.
**Validates: Requirements 9.1**

### Property 22: Environment validation
*For any* instance, the environment field should only accept the values "production", "staging", or "development", rejecting all other values.
**Validates: Requirements 9.2**

### Property 23: Instance computed fields
*For any* instance record, the view representation should display tenant name, app name, service name, environment, and virtual host.
**Validates: Requirements 9.3**

### Property 24: Instance querying by tenant
*For any* tenant with multiple instances, querying instances by tenant should return all and only the instances associated with that tenant.
**Validates: Requirements 9.4**

### Property 25: Instance querying by environment
*For any* environment value, querying instances by environment should return all and only the instances with that environment.
**Validates: Requirements 9.5**

### Property 26: Instance deletion preserves associations
*For any* instance, deleting it should remove only the instance record while the associated tenant, app, and service records remain unchanged.
**Validates: Requirements 9.6**

### Property 27: Instance uniqueness per tenant-app-environment
*For any* existing instance with a specific tenant, app, and environment combination, attempting to create another instance with the same combination should be rejected with a validation error.
**Validates: Requirements 9.7**

## Error Handling

### Validation Errors
- All models implement ActiveRecord validations
- Validation failures return HTTP 422 (Unprocessable Entity)
- Error messages are displayed in forms with field-specific feedback
- Uniqueness violations are caught at the database and model level

### JSON Parsing Errors
- Invalid JSON in virtual attribute setters defaults to empty objects `{}`
- No exceptions are raised to the user
- Graceful degradation ensures data integrity

### AWS Integration Errors
- Missing AWS credentials raise authentication errors
- Missing cluster configuration raises configuration errors
- AWS API errors should be caught and logged (future enhancement)
- Pagination handles large result sets without timeout

### Database Errors
- Foreign key violations (if added) should be caught and displayed
- Record not found errors return HTTP 404
- Concurrent update conflicts use optimistic locking (future enhancement)

## Testing Strategy

### Unit Testing
The system will use Rails' built-in Minitest framework for unit testing. Unit tests will cover:

- Model validations (presence, uniqueness, format)
- Model methods (computed fields, URL parsing, JSON handling)
- Controller actions (CRUD operations, parameter filtering)
- Service object initialization and client creation
- Edge cases (empty JSON, missing fields, nil values)

### Property-Based Testing
The system will use the `rantly` gem for property-based testing in Ruby. Property-based tests will:

- Run a minimum of 100 iterations per property
- Generate random valid and invalid inputs
- Verify universal properties hold across all inputs
- Test round-trip operations (JSON serialization, URL parsing)
- Validate invariants (ordering, uniqueness, computed fields)

Each property-based test will be tagged with a comment explicitly referencing the correctness property from this design document using the format:
```ruby
# Feature: infrastructure-management, Property N: [property description]
```

### Integration Testing
Integration tests will verify:
- Full request/response cycles through controllers
- Form submissions with valid and invalid data
- Flash message display
- Redirect behavior after successful operations

### AWS Integration Testing
AWS integration will use:
- VCR or WebMock for recording/replaying AWS API responses
- Stubbed AWS clients for unit tests
- Separate test credentials for integration tests (if available)

### Test Organization
- Unit tests: `test/models/`, `test/controllers/`
- Property-based tests: `test/properties/`
- Integration tests: `test/integration/`
- Fixtures: `test/fixtures/`

### Coverage Goals
- 90%+ code coverage for models and controllers
- All correctness properties implemented as property-based tests
- Critical paths covered by integration tests
- Edge cases covered by unit tests

## Security Considerations

### Input Validation
- All user inputs are validated at the model level
- Strong parameters prevent mass assignment vulnerabilities
- Repository URLs are validated against strict regex patterns
- JSON fields are parsed safely with error handling

### Authentication & Authorization
- Session-based authentication is implemented (User/Session models)
- Password storage uses bcrypt via `has_secure_password`
- Authorization logic should be added for multi-user scenarios (future enhancement)

### AWS Credentials
- AWS credentials should be stored in environment variables
- Never commit credentials to version control
- Use IAM roles with least privilege principle
- Rotate credentials regularly

### Data Protection
- Sensitive configuration data in JSON fields should be encrypted (future enhancement)
- Database backups should be encrypted
- HTTPS should be enforced in production

## Performance Considerations

### Database Queries
- Index on unique fields (code, name) for fast lookups
- Eager loading for associations (when added)
- Pagination for large result sets

### AWS API Calls
- Implement caching for frequently accessed data (future enhancement)
- Use pagination for ECS queries to handle large clusters
- Rate limiting to avoid AWS API throttling (future enhancement)

### JSON Field Access
- JSON fields are stored as native JSON in SQLite/MySQL
- Parsing happens at the Ruby layer
- Consider caching computed fields for frequently accessed data

## Deployment Considerations

### Environment Configuration
- Database: SQLite for development, MySQL for production
- AWS credentials via environment variables
- Rails credentials for sensitive configuration

### Dependencies
- Ruby 3.x
- Rails 8.x
- AWS SDK gems (s3, ec2, ecs, ecr, elb, cloudwatchlogs, route53)
- Tailwind CSS for styling
- Stimulus for JavaScript interactivity

### Monitoring
- Rails logs for application events
- AWS CloudWatch for infrastructure monitoring
- Error tracking service recommended (Sentry, Rollbar, etc.)

## Future Enhancements

### Planned Features
1. Real-time AWS resource status updates
2. Service deployment automation
3. Database migration management
4. Tenant provisioning workflows
5. Audit logging for all operations
6. API endpoints for programmatic access
7. MCP server implementation for external integrations
8. Multi-user role-based access control
9. Resource usage dashboards
10. Automated backup and restore

### Technical Debt
1. Add comprehensive error handling for AWS API calls
3. Implement caching layer for AWS data
4. Add optimistic locking for concurrent updates
5. Encrypt sensitive JSON configuration data
6. Add API rate limiting
7. Implement background job processing for long-running operations
