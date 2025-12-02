# Requirements Document

## Introduction

The BMS Ops Infrastructure Management System provides a centralized platform for managing multi-tenant AWS infrastructure. The system enables operations teams to manage tenants, applications, services, and databases across AWS ECS environments. Each tenant operates with isolated database schemas while sharing containerized services that run specific versions of applications sourced from GitHub repositories.

## Glossary

- **System**: The BMS Ops Infrastructure Management application
- **Tenant**: A client instance running on the system at a defined level (production, staging, or development)
- **Service**: One or more containers running a specific version of an application on AWS ECS
- **App**: An application sourced from a GitHub, GitLab, or Bitbucket repository
- **Database**: A MySQL database with separate schemas for each tenant
- **AWS ECS**: Amazon Web Services Elastic Container Service
- **Repository**: A version control repository hosted on GitHub, GitLab, or Bitbucket
- **Container**: A Docker container instance running on AWS ECS
- **Schema**: A database namespace isolating tenant data
- **Configuration**: JSON-formatted settings for tenants, services, and databases
- **Instance**: A virtual host representing a Tenant running an App in a specific environment (production, staging, development) serviced by a Service
- **Environment**: The deployment environment level (production, staging, or development)

## Requirements

### Requirement 1

**User Story:** As an operations administrator, I want to manage tenant configurations, so that I can onboard new clients and maintain their infrastructure settings.

#### Acceptance Criteria

1. WHEN an administrator creates a tenant with a unique code and name, THEN the System SHALL persist the tenant record with default configuration values
2. WHEN an administrator updates tenant configuration fields, THEN the System SHALL validate and store the configuration as JSON
3. WHEN an administrator views a tenant, THEN the System SHALL display the tenant code, name, subdomain, database name, service name, SES region, S3 bucket, and computed URL
4. WHEN an administrator deletes a tenant, THEN the System SHALL remove the tenant record from the database
5. WHEN a tenant code is duplicated, THEN the System SHALL reject the creation and display a validation error

### Requirement 2

**User Story:** As an operations administrator, I want to manage application definitions, so that I can track which GitHub repositories are deployed across the infrastructure.

#### Acceptance Criteria

1. WHEN an administrator creates an app with a name and repository URL, THEN the System SHALL validate the repository format and persist the app record
2. WHEN a repository URL is provided, THEN the System SHALL accept GitHub, GitLab, and Bitbucket URLs in HTTPS, SSH, or short formats
3. WHEN an administrator views an app, THEN the System SHALL display the repository owner, repository name, platform, and clean HTTPS URL
4. WHEN an app name is duplicated, THEN the System SHALL reject the creation and display a validation error
5. WHEN a repository URL does not match valid patterns, THEN the System SHALL reject the creation with a format validation error

### Requirement 3

**User Story:** As an operations administrator, I want to manage service definitions, so that I can configure and track containerized services running on AWS ECS.

#### Acceptance Criteria

1. WHEN an administrator creates a service with a name and image, THEN the System SHALL persist the service with empty JSON fields for environment, service_definition, and task_definitions
2. WHEN an administrator provides JSON for environment variables, THEN the System SHALL parse and store the JSON in the environment field
3. WHEN an administrator provides a registry, image, and version, THEN the System SHALL compute the full image reference as registry/image:version
4. WHEN JSON parsing fails for any JSON field, THEN the System SHALL default the field to an empty JSON object
5. WHEN a service name is duplicated, THEN the System SHALL reject the creation and display a validation error

### Requirement 4

**User Story:** As an operations administrator, I want to manage database configurations, so that I can track connection details for tenant databases.

#### Acceptance Criteria

1. WHEN an administrator creates a database with a name, THEN the System SHALL persist the database with an empty connection JSON object
2. WHEN an administrator provides connection JSON with host, port, database, username, and adapter fields, THEN the System SHALL parse and store the connection details
3. WHEN an administrator views a database, THEN the System SHALL display a formatted connection string showing adapter, username, host, port, and database name
4. WHEN connection JSON is not provided, THEN the System SHALL display default values of localhost for host and 5432 for port
5. WHEN a database name is duplicated, THEN the System SHALL reject the creation and display a validation error

### Requirement 5

**User Story:** As an operations administrator, I want to integrate with AWS services, so that I can retrieve and manage ECS clusters, services, containers, and related resources.

#### Acceptance Criteria

1. WHEN the System initializes AWS clients, THEN the System SHALL create authenticated clients for S3, EC2, ECS, ELB, ECR, CloudWatch Logs, and Route53
2. WHEN the System queries ECS for services, THEN the System SHALL retrieve all service ARNs from the configured cluster with pagination support
3. WHEN the System queries ECS for containers, THEN the System SHALL retrieve all container instance ARNs from the configured cluster with pagination support
4. WHEN AWS credentials are not configured, THEN the System SHALL raise an authentication error
5. WHEN the cluster name is not specified in settings, THEN the System SHALL raise a configuration error

### Requirement 6

**User Story:** As an operations administrator, I want the system to validate all input data, so that data integrity is maintained across tenant, app, service, and database records.

#### Acceptance Criteria

1. WHEN any record is created with missing required fields, THEN the System SHALL reject the creation and display field-specific validation errors
2. WHEN any record is created with a duplicate unique field, THEN the System SHALL reject the creation and display a uniqueness validation error
3. WHEN JSON fields are provided with invalid JSON syntax, THEN the System SHALL either parse successfully or default to empty JSON objects
4. WHEN a repository URL contains invalid characters or format, THEN the System SHALL reject the URL with a format validation error
5. WHEN validation fails on update operations, THEN the System SHALL preserve the existing record state and display validation errors

### Requirement 7

**User Story:** As an operations administrator, I want to view lists of all tenants, apps, services, and databases, so that I can monitor and manage the infrastructure at a glance.

#### Acceptance Criteria

1. WHEN an administrator accesses the tenants index, THEN the System SHALL display all tenants ordered by creation date descending
2. WHEN an administrator accesses the apps index, THEN the System SHALL display all apps ordered by creation date descending
3. WHEN an administrator accesses the services index, THEN the System SHALL display all services ordered by creation date descending
4. WHEN an administrator accesses the databases index, THEN the System SHALL display all databases ordered by creation date descending
5. WHEN any index page is empty, THEN the System SHALL display an appropriate empty state message

### Requirement 8

**User Story:** As an operations administrator, I want to parse and extract repository information from various URL formats, so that I can work with repositories from different platforms and URL styles.

#### Acceptance Criteria

1. WHEN a repository URL is in HTTPS format, THEN the System SHALL extract the owner and repository name correctly
2. WHEN a repository URL is in SSH format with git@ prefix, THEN the System SHALL extract the owner and repository name correctly
3. WHEN a repository URL includes a .git suffix, THEN the System SHALL extract the repository name without the suffix
4. WHEN a repository URL is from GitHub, GitLab, or Bitbucket, THEN the System SHALL identify the correct platform
5. WHEN a repository URL is in SSH format, THEN the System SHALL convert it to a clean HTTPS URL for display

### Requirement 9

**User Story:** As an operations administrator, I want to manage instances that connect tenants, apps, services, and environments, so that I can track which tenant is running which app version in which environment.

#### Acceptance Criteria

1. WHEN an administrator creates an instance with a tenant, app, service, and environment, THEN the System SHALL persist the instance with all associations
2. WHEN an administrator specifies an environment for an instance, THEN the System SHALL validate it is one of production, staging, or development
3. WHEN an administrator views an instance, THEN the System SHALL display the tenant name, app name, service name, environment, and virtual host
4. WHEN an administrator queries instances by tenant, THEN the System SHALL return all instances for that tenant
5. WHEN an administrator queries instances by environment, THEN the System SHALL return all instances for that environment
6. WHEN an instance is deleted, THEN the System SHALL remove the instance record without affecting the associated tenant, app, or service
7. WHEN an administrator creates an instance with a duplicate tenant-app-environment combination, THEN the System SHALL reject the creation with a validation error
