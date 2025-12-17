# Implementation Plan

- [x] 1. Set up database schema and core models
  - Create migration for folders table with hierarchical structure
  - Create migration for documents table with content and metadata
  - Create migration for document_versions table for change tracking
  - Add admin column to users table for role-based access
  - _Requirements: 1.1, 1.2, 6.1, 4.1_

- [x] 1.1 Create Document model with validations and associations
  - Implement Document model with title, slug, content, published fields
  - Add belongs_to associations for folder, created_by, updated_by
  - Add has_many association for document_versions
  - Implement slug generation and content change tracking
  - _Requirements: 1.1, 2.2, 6.1_

- [ ]* 1.2 Write property test for document creation and storage
  - **Property 1: Document creation preserves location**
  - **Validates: Requirements 1.1**

- [x] 1.3 Create Folder model with hierarchical structure
  - Implement Folder model with name, slug, parent_id fields
  - Add self-referential associations for parent/children relationships
  - Add validation to prevent circular references
  - Implement slug generation for URL-friendly paths
  - _Requirements: 1.2, 1.4_

- [ ]* 1.4 Write property test for folder hierarchy operations
  - **Property 2: Folder creation adds to hierarchy**
  - **Validates: Requirements 1.2**

- [x] 1.5 Create DocumentVersion model for change tracking
  - Implement DocumentVersion model with content, version_number, change_summary
  - Add belongs_to association for document and created_by
  - Add validation for version uniqueness per document
  - _Requirements: 6.1, 6.2_

- [ ]* 1.6 Write property test for version tracking
  - **Property 21: Change tracking completeness**
  - **Validates: Requirements 6.1**

- [x] 2. Implement core service classes
  - Create MarkdownRenderer service using Rails 8's ActionText for converting markdown to HTML
  - Create DocumentSearchService for full-text search functionality
  - Add proper error handling and validation in services
  - _Requirements: 2.5, 3.4, 5.1_

- [x] 2.1 Create MarkdownRenderer service
  - Implement markdown to HTML conversion using Rails 8's built-in ActionText capabilities
  - Add basic markdown formatting support (headers, bold, italic, links, lists)
  - Include security measures to prevent XSS attacks using ActionText sanitization
  - Support code blocks and embedded media through ActionText
  - _Requirements: 2.5, 3.2_

- [ ]* 2.2 Write property test for markdown rendering
  - **Property 9: Markdown rendering produces valid HTML**
  - **Validates: Requirements 2.5**

- [x] 2.3 Create DocumentSearchService
  - Implement full-text search across document titles and content
  - Add result ranking and relevance scoring
  - Include permission filtering for search results
  - Support search result excerpts and highlighting
  - _Requirements: 3.4, 5.1, 5.2_

- [ ]* 2.4 Write property test for search functionality
  - **Property 12: Search result relevance**
  - **Validates: Requirements 3.4**

- [x] 3. Create controllers with proper authorization
  - Implement DocumentsController with CRUD operations
  - Implement FoldersController for hierarchy management
  - Add admin authorization checks for modification operations
  - Include proper error handling and flash messages
  - _Requirements: 4.1, 4.2, 7.5_

- [x] 3.1 Create DocumentsController
  - Implement index, show, new, create, edit, update, destroy actions
  - Add before_action filters for admin authorization on modifications
  - Include proper parameter filtering and validation
  - Add breadcrumb and navigation context
  - _Requirements: 2.1, 2.2, 2.3, 4.1_

- [ ]* 3.2 Write property test for access control
  - **Property 13: Access control enforcement**
  - **Validates: Requirements 4.1**

- [x] 3.3 Create FoldersController
  - Implement index, show, new, create, edit, update, destroy actions
  - Add validation to prevent deletion of folders containing documents
  - Include hierarchy navigation and breadcrumb support
  - Add document count display for folders
  - _Requirements: 1.2, 1.4, 5.5_

- [ ]* 3.4 Write property test for folder operations
  - **Property 4: Folder deletion validation**
  - **Validates: Requirements 1.4**

- [x] 4. Implement user interface views
  - Create document listing and detail views
  - Create folder hierarchy navigation
  - Implement markdown editor with preview functionality
  - Add search interface and results display
  - _Requirements: 2.1, 3.1, 3.2, 5.1_

- [x] 4.1 Create document views (index, show, new, edit)
  - Implement document listing with folder context
  - Create document detail view with rendered markdown
  - Build markdown editor interface with preview
  - Add document metadata and version history display
  - _Requirements: 2.1, 3.2, 6.2_

- [x] 4.2 Create folder views (index, show, new, edit)
  - Implement hierarchical folder navigation
  - Create folder detail view with contained documents
  - Build folder creation and editing forms
  - Add breadcrumb navigation throughout hierarchy
  - _Requirements: 3.1, 5.3_

- [ ]* 4.3 Write property test for navigation display
  - **Property 10: Hierarchy display completeness**
  - **Validates: Requirements 3.1**

- [x] 4.4 Create search interface and results views
  - Implement search form with query input
  - Create search results page with document excerpts
  - Add search result highlighting and relevance indicators
  - Include hierarchy location context for results
  - _Requirements: 5.1, 5.2_

- [x] 5. Integrate with existing application navigation
  - Update sidebar navigation to include documentation link
  - Add documentation routes to Rails routing configuration
  - Ensure consistent styling with existing BMS Ops interface
  - Add proper authentication integration
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 5.1 Update sidebar navigation
  - Modify shared sidebar partial to include active documentation link
  - Add proper highlighting for current documentation pages
  - Ensure responsive design consistency
  - _Requirements: 3.1, 7.3_

- [x] 5.2 Configure routes and authentication
  - Add RESTful routes for documents and folders
  - Include nested routes for folder-based document organization
  - Ensure authentication requirements match main application
  - Add search and admin-specific routes
  - _Requirements: 7.1, 5.4_

- [ ]* 5.3 Write property test for authentication integration
  - **Property 26: Authentication integration consistency**
  - **Validates: Requirements 7.1**

- [x] 6. Implement advanced features
  - Add file upload support for images and attachments
  - Implement document version comparison and restoration
  - Create admin interface for user permission management
  - Add document publishing and visibility controls
  - _Requirements: 2.4, 6.3, 6.4, 4.2_

- [x] 6.1 Add file upload and attachment support
  - Integrate Active Storage for file uploads
  - Create attachment management interface
  - Generate proper markdown references for uploaded files
  - Add file type validation and security measures
  - _Requirements: 2.4_

- [ ]* 6.2 Write property test for file uploads
  - **Property 8: File upload generates valid references**
  - **Validates: Requirements 2.4**

- [x] 6.3 Implement version comparison and restoration
  - Create version history display interface
  - Add side-by-side version comparison view
  - Implement version restoration functionality
  - Include change summary and author information
  - _Requirements: 6.2, 6.3, 6.4_

- [ ]* 6.4 Write property test for version operations
  - **Property 24: Version restoration integrity**
  - **Validates: Requirements 6.4**

- [x] 6.5 Create admin permission management
  - Build interface for managing user admin status
  - Add document-level permission controls
  - Implement visibility settings for sensitive documents
  - Create permission audit and logging
  - _Requirements: 4.2, 4.4, 4.5_

- [ ]* 6.6 Write property test for permission enforcement
  - **Property 14: Permission enforcement consistency**
  - **Validates: Requirements 4.2**

- [x] 7. Add comprehensive search and navigation features
  - Implement full-text search with PostgreSQL or SQLite FTS
  - Add advanced search filters and sorting options
  - Create bookmark and direct URL support
  - Implement breadcrumb navigation throughout hierarchy
  - _Requirements: 5.1, 5.3, 5.4_

- [x] 7.1 Enhance search functionality
  - Add database indexes for search performance
  - Implement search result ranking and relevance
  - Create search suggestions and autocomplete
  - Add search history and saved searches
  - _Requirements: 5.1, 5.2_

- [ ]* 7.2 Write property test for search completeness
  - **Property 17: Search result completeness**
  - **Validates: Requirements 5.2**

- [x] 7.3 Implement navigation enhancements
  - Create persistent URL structure for all documents
  - Add breadcrumb navigation with proper hierarchy display
  - Implement document and folder bookmarking
  - Add navigation history and recently viewed documents
  - _Requirements: 5.3, 5.4_

- [ ]* 7.4 Write property test for URL persistence
  - **Property 19: URL persistence**
  - **Validates: Requirements 5.4**

- [x] 8. Final integration and testing
  - Ensure all tests pass, ask the user if questions arise
  - Verify integration with existing BMS Ops styling and patterns
  - Test error handling and flash message consistency
  - Validate responsive design and mobile compatibility
  - _Requirements: 7.2, 7.5_

- [ ]* 8.1 Write comprehensive property tests for remaining properties
  - **Property 3: Document movement preserves content integrity** - **Validates: Requirements 1.3**
  - **Property 5: Rename operations preserve references** - **Validates: Requirements 1.5**
  - **Property 6: Markdown content round trip** - **Validates: Requirements 2.2**
  - **Property 7: Document editing preserves content** - **Validates: Requirements 2.3**
  - **Property 11: Document rendering consistency** - **Validates: Requirements 3.2**
  - **Property 15: Document visibility filtering** - **Validates: Requirements 4.3**
  - **Property 16: Administrator-only access control** - **Validates: Requirements 4.5**
  - **Property 18: Breadcrumb accuracy** - **Validates: Requirements 5.3**
  - **Property 20: Folder metadata accuracy** - **Validates: Requirements 5.5**
  - **Property 22: History display accuracy** - **Validates: Requirements 6.2**
  - **Property 23: Version comparison accuracy** - **Validates: Requirements 6.3**
  - **Property 25: Soft deletion and recovery** - **Validates: Requirements 6.5**
  - **Property 27: Error handling consistency** - **Validates: Requirements 7.5**

- [x] 8.2 Final integration verification
  - Run full test suite to ensure all functionality works correctly
  - Verify consistent styling and user experience
  - Test all user workflows from creation to deletion
  - Validate performance with realistic document volumes
  - _Requirements: All requirements_