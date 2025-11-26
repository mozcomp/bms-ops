Using the detail provided in the updated Readme.md expand on the copilot instructions already provided

copilot-instructions.md+8-2
copilot-instructions.md+2-0
copilot-instructions.md+2-0
copilot-instructions.md+48-0
Updated copilot-instructions.md with comprehensive domain model and architecture details:

Key Additions:
Clarified Purpose: BMS = Business Management System for AWS ECS infrastructure management and tenant onboarding

Domain Model Architecture Section:

Service: Maps 1:1 to AWS ECS services, runs specific app versions, associates with tenants via NGINX
App: GitHub repository references for deployable applications
Tenant: Client environments (prod/staging/dev) with isolated database schemas
Database: Multi-tenant schema isolation with service-level migration tracking
Key Relationships: Documented the entity relationships and NGINX-based routing

AWS ECS Integration: Noted the 1:1 service mapping and version-specific deployments

MCP Server Architecture: Outlined the planned Model Context Protocol server for API operations (deploy, scale, tenant onboarding, schema management)

Multi-tenancy Considerations: Added notes about schema isolation and potential use of apartment gem

The instructions now provide AI agents with essential context about:

The multi-tenant architecture pattern
AWS ECS service orchestration
Database schema isolation strategy
Planned MCP server integration
Domain entities that need to be created
This gives agents immediate understanding of the business domain and architectural decisions when implementing features like tenant onboarding, service deployment, or database migrations.