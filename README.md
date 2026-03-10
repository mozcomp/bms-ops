# README

The objective for this app is to provide an interface to manage the AWS resources and services to run the BMS infrastructure, and to maintaina and onboard tenants to the system.

BMS runs as a number of services, each service running a specific version of one of the apps held within the codebase.

We will define an API for the various actions required, and implement an MCP Server to provide access to services provided.

Initially we'll use SQLite as the database.

The UI will be based on Tailwind.



Questions for Refinement:
Business Domain: What does "BMS Ops" stand for? Is this a building management system, business management, or something else? Understanding the domain could help document domain-specific patterns.

Missing Models/Business Logic: I noticed no custom models in the workspace structure. Are you planning to add domain models, or is this primarily a UI-focused admin interface?

Authentication/Authorization: Should I document any planned auth patterns? (No auth gems were detected in the Gemfile)

API Integration: Are there external APIs or services this app integrates with that agents should know about?

Testing Patterns: Should I add specific testing conventions once you develop custom features beyond Rails UI pages?



Models:

Service:
A service is one or more containers running the specific version of an app.
It is a one for one relationship with the service running on AWS ECS.
One or more tenants are nominated as being serviced by a service, mainly by the server_name definition within an NGINX configuration.

App:
Each app is sourced from a Github project.

Tenant:
A tenant relates to a specific client running on the system at a defined level. Separate tenants would exist fo a customers' production system, as against their staging or development system.

Database:
A separate schema is specified for each tenant.
A service would specify the migration level for a database.

Docker API:
https://docs.docker.com/reference/api/hub/latest/

