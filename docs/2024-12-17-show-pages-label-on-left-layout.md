# Show Pages Label on Left Layout Update

**Date:** December 17, 2024  
**Task:** Update show pages to use "label on left" format and display code field in Basic Information heading

## Task Overview

Updated all show page views to use the same "label on left" layout pattern as the forms for consistency. Also added code field display in the top right of the Basic Information heading area for objects that have a code field (like tenants).

## Key Changes

### 1. Show Page Views Updated

Updated all main resource show pages to use the "label on left" pattern:

#### **app/views/tenants/show.html.erb**
- Updated Basic Information and Contact Information sections to use label-on-left layout
- Added tenant code badge in top right of Basic Information heading
- Converted from 2-column grid layout to consistent label-on-left pattern
- Maintained all existing functionality and links

#### **app/views/instances/show.html.erb**
- Updated Deployment Information section to use label-on-left layout
- Updated Environment Variables section to use label-on-left pattern
- Converted from grid layout to consistent spacing and alignment
- Preserved all association links and computed fields

#### **app/views/apps/show.html.erb**
- Updated Application Information and Repository sections
- Converted from grid layout to label-on-left pattern
- Maintained repository URL display and external links
- Preserved platform and owner information display

#### **app/views/services/show.html.erb**
- Updated Service Information section to use label-on-left layout
- Converted from grid layout to consistent pattern
- Maintained version badges and container image display
- Preserved all JSON configuration sections

#### **app/views/databases/show.html.erb**
- Updated Database Information and Connection Details sections
- Converted from grid layout to label-on-left pattern
- Maintained connection string display and adapter information
- Preserved JSON configuration display

### 2. UI Patterns Documentation Updated

**File:** `.kiro/steering/ui-patterns.md`
- Added comprehensive show page patterns section
- Documented "label on left" pattern for show pages
- Added code field display pattern for Basic Information headings
- Included examples for different field types (links, badges, code blocks)
- Established consistent spacing and layout guidelines

### Technical Implementation

#### Layout Pattern Structure
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <dt class="text-sm font-medium text-slate-500 dark:text-slate-400">Field Label</dt>
  </div>
  <div class="flex-1 min-w-0">
    <dd class="text-sm text-slate-900 dark:text-slate-100">Field Value</dd>
  </div>
</div>
```

#### Code Field in Heading
```erb
<div class="flex items-center justify-between">
  <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">Basic Information</h2>
  <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-800 dark:text-primary-400">
    <%= resource.code %>
  </span>
</div>
```

### Design Decisions

- **Consistent Width**: Used 192px (w-48) for labels to match form layout
- **Proper Spacing**: Used 24px (gap-6) between label and content
- **Responsive Design**: Labels remain left-aligned on all screen sizes
- **Code Field Placement**: Added code badges in top right of Basic Information headings
- **Content Alignment**: Used `items-start` for proper alignment with multi-line content
- **Container Structure**: `flex-1 min-w-0` allows content to fill remaining space

### Benefits

1. **Visual Consistency**: Show pages now match form layout patterns exactly
2. **Improved Scanning**: Users can quickly scan labels in the left column
3. **Better Organization**: Code fields are prominently displayed in headings
4. **Professional Appearance**: Clean, organized layout matches modern UI standards
5. **Maintainability**: Standardized pattern makes future development easier
6. **Accessibility**: Proper semantic markup with dt/dd elements

### Testing

- **Controller Tests**: All 82 controller tests pass
- **Show Page Functionality**: All links, badges, and content display correctly
- **Responsive Design**: Layout works correctly across different screen sizes
- **Code Field Display**: Tenant code appears correctly in Basic Information heading

## Next Steps

- All new show pages should follow the documented "label on left" pattern
- Code fields should be displayed in the top right of Basic Information headings when present
- The UI patterns documentation serves as the reference for all future show page development
- Consider applying this pattern to any remaining detail views in the application