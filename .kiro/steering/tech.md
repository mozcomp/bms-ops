# BMS Ops Technology Stack

## Framework & Runtime
- **Rails 8.1.1**: Modern Rails application with latest features
- **Ruby**: Primary backend language
- **SQLite**: Development and initial production database
- **Trilogy**: MySQL adapter for production scaling

## Frontend Stack
- **Tailwind CSS**: Utility-first CSS framework for styling
- **Hotwire (Turbo + Stimulus)**: SPA-like experience without complex JavaScript
- **Import Maps**: Modern JavaScript module management
- **RailsUI Pro**: Premium UI component library for consistent design

## AWS Integration
Comprehensive AWS SDK integration for infrastructure management:
- **aws-sdk-s3**: Object storage management
- **aws-sdk-ecs**: Container orchestration
- **aws-sdk-ec2**: Virtual machine management
- **aws-sdk-ecr**: Container registry operations
- **aws-sdk-elasticloadbalancingv2**: Load balancer configuration
- **aws-sdk-route53**: DNS management
- **aws-sdk-cloudwatchlogs**: Logging and monitoring

## Authentication & Security
- **bcrypt**: Secure password hashing
- **Solid Cache/Queue/Cable**: Database-backed Rails infrastructure

## Development Tools
- **Kamal**: Docker-based deployment system
- **Thruster**: HTTP asset caching and compression
- **Bootsnap**: Boot time optimization
- **Propshaft**: Modern asset pipeline

## Testing & Quality
- **Capybara + Selenium**: System testing
- **Rantly**: Property-based testing for robust validation
- **RuboCop Rails Omakase**: Code style enforcement
- **Brakeman**: Security vulnerability scanning
- **Bundler Audit**: Gem security auditing

## Common Commands

### Development Server
```bash
# Start development server with CSS watching
bin/dev

# Or start components separately
bin/rails server -p 3000
bin/rails tailwindcss:watch
```

### Database Operations
```bash
# Setup database
bin/rails db:setup

# Run migrations
bin/rails db:migrate

# Reset database
bin/rails db:reset
```

### Testing
```bash
# Run all tests
bin/rails test

# Run system tests
bin/rails test:system

# Run specific test file
bin/rails test test/models/tenant_test.rb

# Run property-based tests
bin/rails test test/properties/
```

### Code Quality
```bash
# Run RuboCop linting
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -A

# Security audit
bundle exec brakeman
bundle exec bundler-audit
```

### Asset Management
```bash
# Precompile assets for production
bin/rails assets:precompile

# Clean compiled assets
bin/rails assets:clobber
```

### Deployment
```bash
# Deploy with Kamal
kamal deploy

# Check deployment status
kamal app logs
```

## Environment Configuration
- **Development**: Uses SQLite, .env file for configuration
- **Production**: Trilogy/MySQL, AWS credentials required
- **Environment Variables**: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY required for AWS operations

## Architecture Notes
- **Service Objects**: AWS operations encapsulated in service classes
- **JSON Fields**: Extensive use of JSON columns for flexible configuration storage
- **Structured Logging**: JSON-formatted logs for better parsing and monitoring
- **Multi-tenant**: Database-per-tenant schema isolation pattern