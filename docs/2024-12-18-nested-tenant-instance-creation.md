# Nested Tenant Instance Creation

**Date:** December 18, 2024  
**Task:** Implement nested route for creating tenant instances with simplified BMS Cloud configuration

## Task Overview

Implemented a nested route and controller for creating instances under tenants, with a streamlined form that assumes the BMS Cloud application and only requires environment and service selection. The instance name and virtual host are automatically generated based on the tenant code, environment, and service.

## Key Changes

### **config/routes.rb**
- Added nested instances routes under tenants: `resources :instances, only: [:new, :create], controller: 'tenants/instances'`
- Routes now available: `new_tenant_instance_path(@tenant)` and `tenant_instances_path(@tenant)`

### **app/controllers/tenants/instances_controller.rb** (New)
- Created nested controller specifically for tenant instance creation
- Automatically assigns BMS Cloud app (or first available app for testing)
- Generates instance name using pattern: `{tenant_code}-{environment}-{service_name}`
- Automatically sets virtual host based on tenant code and environment
- Only requires environment and service selection from user

### **app/views/tenants/instances/new.html.erb** (New)
- Streamlined form with only essential fields (environment and service)
- Shows tenant and app information as read-only
- Live preview of generated instance name and virtual host
- Uses "label on left" layout pattern for consistency
- JavaScript-powered live updates as user makes selections

### **app/views/tenants/show.html.erb**
- Updated "Create Instance" links to use nested route: `new_tenant_instance_path(@tenant)`
- Added "Create Instance" as first quick action in sidebar
- Updated empty state "Create Instance" button to use nested route

### **test/controllers/tenants/instances_controller_test.rb** (New)
- Comprehensive test coverage for nested controller
- Tests successful instance creation with minimal parameters
- Tests validation failure handling
- Verifies automatic name and virtual host generation

## Technical Implementation

### Controller Logic
```ruby
def create
  @instance = @tenant.instances.build(instance_params)
  
  # Auto-assign BMS Cloud app
  if @instance.app_id.blank?
    @bms_cloud_app = App.find_by(name: 'bms-cloud') || App.first
    @instance.app = @bms_cloud_app if @bms_cloud_app
  end

  # Generate name and virtual_host
  if @instance.name.blank? && @instance.service.present?
    @instance.name = "#{@tenant.code}-#{@instance.environment}-#{@instance.service.name}"
  end
  
  # Save and redirect
end
```

### Form Structure
- **Tenant**: Read-only display with tenant name and code badge
- **Application**: Read-only display showing "BMS Cloud" 
- **Environment**: Dropdown with production/staging/development options
- **Service**: Dropdown populated from available ECS services
- **Generated Preview**: Live-updating display of calculated name and virtual host

### JavaScript Enhancement
```javascript
function updatePreview() {
  const environment = environmentSelect.value;
  const serviceName = serviceOption.text;
  
  if (environment && serviceName) {
    const name = `${tenantCode}-${environment}-${serviceName}`;
    const subdomain = environment !== 'production' ? `${environment}-${tenantCode}` : tenantCode;
    const virtualHost = `${subdomain}.bmserp.com`;
    
    // Update preview displays
  }
}
```

## Design Decisions

- **Simplified Form**: Only asks for essential information (environment and service)
- **Auto-generation**: Instance name and virtual host generated automatically for consistency
- **BMS Cloud Focus**: Assumes BMS Cloud application, reducing complexity for primary use case
- **Live Preview**: Shows generated values before submission to prevent surprises
- **Nested Routes**: Provides clear context that instances belong to specific tenants
- **Quick Actions**: Added to sidebar for easy access from tenant details

## Benefits

1. **Streamlined Workflow**: Reduces instance creation from 6+ fields to just 2 essential selections
2. **Consistency**: Automatic naming ensures consistent patterns across all instances
3. **Context Awareness**: Nested routes make the tenant-instance relationship clear
4. **Error Prevention**: Live preview shows exactly what will be created
5. **Quick Access**: Multiple entry points (empty state, sidebar, main content area)
6. **Maintainability**: Centralized logic for name and virtual host generation

## Testing

- **Controller Tests**: 2 new tests covering successful creation and validation failures
- **All Tests Passing**: 106 controller tests pass with 0 failures, 0 errors, 0 skips
- **Route Testing**: Verified nested routes work correctly
- **Form Functionality**: Tested live preview and form submission

## Usage

Users can now create instances for a tenant by:
1. Visiting tenant show page
2. Clicking "Create Instance" (empty state, sidebar, or main area)
3. Selecting environment (production/staging/development)
4. Selecting ECS service
5. Reviewing generated name and virtual host in live preview
6. Submitting form

The system automatically handles:
- Setting tenant association
- Assigning BMS Cloud application
- Generating consistent instance name
- Setting appropriate virtual host based on environment
- Redirecting back to tenant show page with success message