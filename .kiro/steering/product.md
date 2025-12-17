# BMS Ops Product Overview

BMS Ops is a web-based management interface for AWS infrastructure that supports a multi-tenant Building Management System (BMS). The application provides centralized control over AWS resources and services required to run BMS infrastructure and onboard new tenants.

## Core Purpose

- **Infrastructure Management**: Manage AWS resources (ECS services, EC2 instances, databases, load balancers) through a unified interface
- **Tenant Onboarding**: Streamline the process of adding new clients to the BMS system with proper isolation and configuration
- **Service Orchestration**: Deploy and manage different versions of BMS applications across multiple environments (production, staging, development)
- **Resource Monitoring**: Track and monitor AWS resources, services, and tenant-specific configurations

## Key Domain Concepts

### Tenant
Represents a specific client running on the system at a defined environment level (production, staging, development). Each tenant has:
- Unique code and subdomain configuration
- Dedicated database schema
- Isolated AWS resources (S3 buckets, SES configuration)
- Custom service configurations

### Service
One-to-one relationship with AWS ECS services. Represents containers running specific versions of applications. Services:
- Run specific app versions with defined configurations
- Serve one or more tenants via NGINX server_name definitions
- Maintain environment variables and task definitions
- Track deployment status and health

### App
Source applications from GitHub repositories that get deployed as services. Apps define:
- Repository location and build configuration
- Versioning and deployment targets
- Container image specifications

### Database
Separate schemas for tenant isolation. Databases track:
- Connection configurations
- Migration levels per service
- Multi-tenant data separation

## Target Users

- DevOps engineers managing BMS infrastructure
- System administrators onboarding new tenants
- Operations teams monitoring service health and performance