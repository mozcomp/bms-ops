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

