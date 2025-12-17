# Design Document

## Overview

The logging and monitoring system will provide comprehensive observability for the BMS Ops application through structured logging, health monitoring, performance metrics collection, and alerting capabilities. The design follows a layered architecture with clear separation between logging infrastructure, metrics collection, health checking, and user-facing monitoring interfaces.

## Architecture

The system consists of four main components:

1. **Logging Layer**: Structured logging infrastructure with JSON formatting and configurable destinations
2. **Health Check Layer**: HTTP endpoints for system health verification and dependency monitoring  
3. **Metrics Collection Layer**: Performance data gathering with time-series storage and aggregation
4. **Monitoring Dashboard**: Web-based interface for real-time system status visualization
5. **Alerting Engine**: Rule-based notification system for critical events

The architecture follows Rails conventions with service objects for complex operations, concerns for shared functionality, and background jobs for asynchronous processing.

## Components and Interfaces

### Logging Infrastructure

**LoggingService**
- `log_event(level, message, context = {})`: Creates structured log entries
- `configure_destination(type, options)`: Sets up log output destinations
- `format_entry(entry)`: Converts log data to structured JSON format

**LogEntry Model**
- Attributes: `timestamp`, `level`, `message`, `context`, `request_id`, `user_id`
- Validations: Required timestamp and level, valid severity levels
- Scopes: By level, time range, request context

### Health Check System

**HealthCheckController**
- `GET /health`: Basic health status endpoint
- `GET /health/detailed`: Comprehensive health information with dependencies
- Response format: JSON with status, checks, and timestamps

**HealthCheckService**
- `check_system_health()`: Aggregates all health checks
- `check_database()`: Verifies database connectivity
- `check_external_services()`: Tests external API availability
- `check_disk_space()`: Monitors storage capacity

### Metrics Collection

**MetricsCollector**
- `record_request_time(duration, endpoint)`: Tracks HTTP response times
- `record_resource_usage(cpu, memory)`: Captures system resource metrics
- `record_database_query(duration, query_type)`: Measures database performance

**Metric Model**
- Attributes: `name`, `value`, `timestamp`, `tags`, `aggregation_period`
- Indexes: Compound indexes on name+timestamp for efficient querying
- Aggregation methods for time-series data

### Monitoring Dashboard

**MonitoringController**
- `GET /monitoring`: Main dashboard view
- `GET /monitoring/api/metrics`: JSON API for real-time data
- `GET /monitoring/api/health`: Current health status API

**Dashboard Components**
- Real-time health status indicators
- Performance metrics charts (response times, resource usage)
- Recent log entries with filtering
- System dependency status grid

### Alerting System

**AlertingService**
- `evaluate_rules()`: Checks alert conditions against current metrics
- `send_alert(alert_type, details)`: Delivers notifications via configured channels
- `resolve_alert(alert_id)`: Marks alerts as resolved

**Alert Model**
- Attributes: `rule_name`, `condition`, `status`, `triggered_at`, `resolved_at`
- States: `triggered`, `acknowledged`, `resolved`
- Notification channels: email, webhook, Slack integration

## Data Models

### LogEntry
```ruby
class LogEntry < ApplicationRecord
  validates :timestamp, :level, :message, presence: true
  validates :level, inclusion: { in: %w[debug info warn error fatal] }
  
  scope :by_level, ->(level) { where(level: level) }
  scope :recent, ->(hours = 24) { where('timestamp > ?', hours.hours.ago) }
  scope :for_request, ->(request_id) { where(request_id: request_id) }
end
```

### Metric
```ruby
class Metric < ApplicationRecord
  validates :name, :value, :timestamp, presence: true
  validates :value, numericality: true
  
  scope :by_name, ->(name) { where(name: name) }
  scope :time_range, ->(start_time, end_time) { where(timestamp: start_time..end_time) }
  
  def self.aggregate_by_minute(name, start_time, end_time)
    # Time-series aggregation logic
  end
end
```

### Alert
```ruby
class Alert < ApplicationRecord
  validates :rule_name, :condition, :status, presence: true
  validates :status, inclusion: { in: %w[triggered acknowledged resolved] }
  
  scope :active, -> { where(status: ['triggered', 'acknowledged']) }
  scope :recent, ->(hours = 24) { where('triggered_at > ?', hours.hours.ago) }
end
```

### HealthCheck
```ruby
class HealthCheck < ApplicationRecord
  validates :name, :status, :checked_at, presence: true
  validates :status, inclusion: { in: %w[healthy unhealthy unknown] }
  
  scope :current, -> { where('checked_at > ?', 5.minutes.ago) }
  scope :unhealthy, -> { where(status: 'unhealthy') }
end
```
## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Property 1: Log entry creation completeness
*For any* system event, when a log entry is created, it should contain all required fields: timestamp, severity level, message, and contextual metadata
**Validates: Requirements 1.1**

Property 2: Log entry JSON serialization
*For any* log entry, when it is formatted for output, the result should be valid JSON with the expected structure containing all log entry fields
**Validates: Requirements 1.2**

Property 3: Log entry persistence immediacy
*For any* log entry, when it is written to the logging destination, it should be immediately available for retrieval from that destination
**Validates: Requirements 1.3**

Property 4: Concurrent logging chronological ordering
*For any* set of log entries created concurrently, when they are persisted, they should maintain chronological ordering based on their timestamps
**Validates: Requirements 1.4**

Property 5: Logging failure resilience
*For any* system operation, when logging fails, the operation should complete successfully without data loss or system failure
**Validates: Requirements 1.5**

Property 6: Health check failure response
*For any* critical system component failure, when a health check is requested, the system should return HTTP 503 status with details about the failed component
**Validates: Requirements 2.3**

Property 7: Health check dependency reporting
*For any* external service dependency state, when a health check is performed, the response should accurately reflect the current status of that dependency
**Validates: Requirements 2.5**

Property 8: Historical metrics data retrieval
*For any* request for historical metrics data, when the request specifies the past 24 hours, the system should return all metrics within that exact time range
**Validates: Requirements 3.4**

Property 9: Concurrent dashboard data consistency
*For any* set of concurrent dashboard data requests, when they are processed simultaneously, all requests should receive identical data for the same timestamp
**Validates: Requirements 3.5**

Property 10: Alert notification delivery
*For any* alert condition that is met, when the alert is triggered, notifications should be delivered to all configured channels
**Validates: Requirements 4.2**

Property 11: Alert notification content completeness
*For any* alert notification, when it is sent, it should include error details and recommended actions as specified in the alert configuration
**Validates: Requirements 4.3**

Property 12: Alert resolution notification
*For any* alert that resolves, when the resolution occurs, resolution notifications should be automatically sent to the same channels that received the original alert
**Validates: Requirements 4.4**

Property 13: Alert delivery retry mechanism
*For any* alert notification that fails to deliver, when the failure is detected, the system should attempt delivery via alternative configured channels
**Validates: Requirements 4.5**

Property 14: HTTP request metrics recording
*For any* HTTP request processed by the system, when the request completes, a response time performance metric should be recorded with accurate timing data
**Validates: Requirements 5.1**

Property 15: System resource metrics collection
*For any* system resource consumption event, when CPU or memory usage changes, corresponding performance metrics should be collected and stored
**Validates: Requirements 5.2**

Property 16: Database operation metrics recording
*For any* database operation, when it executes, the query execution time should be measured and recorded as a performance metric
**Validates: Requirements 5.3**

Property 17: Performance metrics aggregation
*For any* performance metric data collected, when the aggregation period completes, measurements should be aggregated into 1-minute intervals
**Validates: Requirements 5.4**

Property 18: Automatic metrics archival
*For any* performance metric storage that reaches capacity limits, when the limit is detected, historical data should be automatically archived to maintain system performance
**Validates: Requirements 5.5**

## Error Handling

The system implements comprehensive error handling across all components:

**Logging Errors**
- Failed log writes continue system operation without blocking
- Fallback to alternative logging destinations when primary fails
- Error logging uses separate, isolated logging channel to prevent recursion

**Health Check Errors**
- Individual component check failures don't prevent overall health reporting
- Timeout handling for slow dependency checks
- Graceful degradation when health check infrastructure fails

**Metrics Collection Errors**
- Failed metric collection doesn't impact application performance
- Metric storage failures trigger automatic cleanup and archival
- Invalid metric data is logged and discarded without system impact

**Dashboard Errors**
- API failures return appropriate HTTP status codes with error details
- Frontend gracefully handles missing or delayed data
- Real-time updates continue even if some data sources fail

**Alerting Errors**
- Alert evaluation failures are logged but don't prevent other alerts
- Notification delivery failures trigger retry mechanisms
- Alert system maintains state consistency even during partial failures

## Testing Strategy

The testing approach combines unit testing for specific functionality with property-based testing for universal behaviors:

**Unit Testing**
- Component integration testing for health check endpoints
- Dashboard API response format validation
- Alert notification delivery verification
- Metrics aggregation accuracy testing
- Error handling scenario coverage

**Property-Based Testing**
- Universal logging behavior across all system events
- Health check response consistency under various system states
- Metrics collection accuracy across different data types
- Alert delivery reliability across multiple notification channels
- Data consistency under concurrent access patterns

**Property-Based Testing Framework**
- Use Ruby's `rantly` gem for property-based testing
- Configure each property test to run minimum 100 iterations
- Tag each property test with explicit reference to design document properties
- Format: `**Feature: logging-monitoring, Property {number}: {property_text}**`

**Integration Testing**
- End-to-end logging flow from event to dashboard display
- Complete alert lifecycle from trigger to resolution
- Health check integration with external dependencies
- Metrics collection and aggregation pipeline testing

**Performance Testing**
- Health check response time validation
- Dashboard load time measurement
- Metrics collection overhead assessment
- Alert delivery latency verification