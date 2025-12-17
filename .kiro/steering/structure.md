# BMS Ops Project Structure

## Application Organization

### Core MVC Structure
```
app/
├── controllers/          # Request handling and flow control
│   ├── concerns/        # Shared controller functionality
│   │   ├── application_logging.rb    # Structured logging
│   │   ├── authentication.rb         # User session management
│   │   └── aws_error_handling.rb     # AWS API error handling
│   ├── dashboard_controller.rb       # Main dashboard
│   ├── tenants_controller.rb         # Tenant management
│   ├── services_controller.rb        # ECS service management
│   ├── apps_controller.rb            # Application repository management
│   ├── databases_controller.rb       # Database configuration
│   └── instances_controller.rb       # EC2 instance management
├── models/              # Domain logic and data persistence
│   ├── concerns/        # Shared model functionality
│   ├── tenant.rb        # Multi-tenant client representation
│   ├── service.rb       # ECS service configuration
│   ├── app.rb          # GitHub repository applications
│   ├── database.rb     # Database connection management
│   ├── instance.rb     # EC2 instance representation
│   ├── user.rb         # Authentication and user management
│   └── session.rb      # User session handling
├── services/           # Business logic and external integrations
│   ├── aws_service.rb  # AWS SDK client management
│   ├── logging_service.rb           # Centralized logging
│   ├── resources.rb    # AWS resource aggregation
│   └── resource/       # Individual AWS resource handlers
│       ├── base.rb     # Common resource functionality
│       ├── cluster.rb  # ECS cluster management
│       ├── container.rb # Container operations
│       ├── service.rb  # ECS service operations
│       └── task.rb     # ECS task management
└── views/              # UI templates and components
    ├── layouts/        # Application layout templates
    ├── shared/         # Reusable UI components
    │   ├── _sidebar.html.erb         # Navigation sidebar
    │   ├── _topbar.html.erb          # Top navigation
    │   └── _flash_messages.html.erb  # User notifications
    ├── dashboard/      # Dashboard views
    ├── tenants/        # Tenant CRUD views
    ├── services/       # Service management views
    ├── apps/          # Application management views
    ├── databases/     # Database configuration views
    └── rui/           # RailsUI demo pages (development)
```

## Configuration & Infrastructure

### Configuration Files
```
config/
├── application.rb      # Main Rails configuration
├── routes.rb          # URL routing definitions
├── database.yml       # Database connection settings
├── deploy.yml         # Kamal deployment configuration
├── importmap.rb       # JavaScript module imports
├── environments/      # Environment-specific settings
└── initializers/      # Framework and gem configuration
```

### Database Schema
```
db/
├── migrate/           # Database migration files
│   ├── *_create_users.rb           # User authentication
│   ├── *_create_sessions.rb        # Session management
│   ├── *_create_tenants.rb         # Multi-tenant setup
│   ├── *_create_services.rb        # ECS service tracking
│   ├── *_create_apps.rb            # Application repositories
│   ├── *_create_databases.rb       # Database configurations
│   ├── *_create_instances.rb       # EC2 instance tracking
│   └── *_create_log_entries.rb     # Centralized logging
├── schema.rb          # Current database structure
└── seeds.rb           # Initial data setup
```

## Testing Structure

### Test Organization
```
test/
├── controllers/       # Controller integration tests
│   └── concerns/     # Controller concern tests
├── models/           # Model unit tests
├── services/         # Service object tests
├── properties/       # Property-based tests using Rantly
│   ├── *_properties_test.rb        # Domain model properties
│   └── aws_pagination_properties_test.rb  # AWS API behavior
├── fixtures/         # Test data definitions
├── helpers/          # Test helper utilities
└── system/           # End-to-end browser tests
```

## Asset Organization

### Frontend Assets
```
app/assets/
├── stylesheets/
│   ├── application.css              # Main stylesheet entry
│   └── railsui/                    # RailsUI component styles
├── images/
│   └── railsui/                    # UI component images
└── tailwind/
    └── application.css             # Tailwind CSS entry point

app/javascript/
├── application.js                  # Main JavaScript entry
└── controllers/                    # Stimulus controllers
    ├── application.js              # Stimulus application setup
    ├── flash_controller.js         # Flash message handling
    ├── search_controller.js        # Search functionality
    ├── sidebar_controller.js       # Sidebar interactions
    └── railsui/                    # RailsUI Stimulus controllers
```

## Key Architectural Patterns

### Service Layer Pattern
- **AWS Service Module**: Centralized AWS SDK client management with error handling
- **Resource Services**: Individual AWS resource type handlers (ECS, EC2, RDS)
- **Logging Service**: Structured logging across the application

### Model Conventions
- **JSON Configuration Fields**: Extensive use of JSON columns for flexible configuration
- **Virtual Attributes**: JSON field accessors with sensible defaults
- **Validation Patterns**: Comprehensive validation with custom error messages
- **Association Patterns**: Clear has_many/belongs_to relationships with proper cleanup

### Controller Concerns
- **ApplicationLogging**: Structured request/response logging
- **Authentication**: Session-based user authentication
- **AwsErrorHandling**: Consistent AWS API error handling and user feedback

### View Patterns
- **Component-based UI**: Reusable partials following RailsUI patterns
- **Consistent Layouts**: Sidebar + topbar layout with responsive design
- **Form Conventions**: Standardized form layouts with error handling
- **Table Patterns**: Consistent data table styling and interactions

### Testing Conventions
- **Property-based Testing**: Using Rantly for robust model validation testing
- **Service Testing**: Comprehensive AWS service integration testing
- **Controller Testing**: Full request/response cycle testing
- **System Testing**: End-to-end browser automation with Capybara

## File Naming Conventions
- **Models**: Singular, snake_case (e.g., `tenant.rb`, `log_entry.rb`)
- **Controllers**: Plural, snake_case with `_controller` suffix
- **Services**: Descriptive names with `_service` suffix or module organization
- **Views**: Match controller actions, organized in controller-named directories
- **Tests**: Mirror source file structure with `_test` suffix
- **Migrations**: Timestamped with descriptive action names