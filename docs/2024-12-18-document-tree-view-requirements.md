# Document Tree View Requirements

**Date:** December 18, 2024  
**Task:** Implement tree view UI for document folders with add folder/file buttons and file selection

## Requirements Based on Reference Image

### Tree View Structure
- Hierarchical folder/file display with expand/collapse functionality
- Visual indicators:
  - `-` icon for expanded folders
  - `+` icon for collapsed folders
  - Folder icon for directories
  - File icon for documents
- Indentation to show nesting levels
- Click on folder to expand/collapse
- Click on file to select/view

### Add Buttons
- "Add Folder" button at appropriate levels
- "Add File" button at appropriate levels
- Buttons should appear contextually (on hover or always visible)

### File Selection
- Click on file name to select
- Visual indication of selected file
- Load file content in main area when selected

## Implementation Plan

### 1. Create Tree View Partial
**File:** `app/views/shared/_document_tree.html.erb`
- Recursive partial for rendering folder hierarchy
- Expand/collapse state management
- Add folder/file buttons

### 2. Add Stimulus Controller
**File:** `app/javascript/controllers/document_tree_controller.js`
- Handle expand/collapse interactions
- Manage selection state
- Handle add folder/file button clicks
- Persist expanded state in localStorage

### 3. Update Documents Index View
**File:** `app/views/documents/index.html.erb`
- Replace current folder grid with tree view sidebar
- Split layout: tree view on left, content on right
- Responsive design for mobile

### 4. Add CSS Styles
- Tree view indentation
- Hover states
- Selection highlighting
- Icon positioning
- Button styling

### 5. Update Controllers
- Add AJAX endpoints for folder operations
- Handle file selection state
- Return JSON for dynamic updates

## UI Layout Structure

```
┌─────────────────────────────────────────────────┐
│  Topbar                                         │
├──────────┬──────────────────────────────────────┤
│          │                                      │
│  Tree    │  Document Content Area               │
│  View    │                                      │
│          │  - Selected document display         │
│  [+] [-] │  - Or folder contents                │
│  Folders │  - Or empty state                    │
│  Files   │                                      │
│          │                                      │
│  [Add]   │                                      │
│  Buttons │                                      │
│          │                                      │
└──────────┴──────────────────────────────────────┘
```

## Key Features

1. **Expand/Collapse**
   - Click folder name or icon to toggle
   - Remember state across page loads
   - Smooth animation

2. **File Selection**
   - Single file selection
   - Highlight selected file
   - Load content dynamically or navigate

3. **Add Operations**
   - Add folder button (creates subfolder)
   - Add file button (creates new document)
   - Context-aware placement

4. **Visual Design**
   - Consistent with existing UI patterns
   - Dark mode support
   - Accessible keyboard navigation

## Technical Considerations

- Use Stimulus for JavaScript interactions
- Turbo for dynamic updates
- LocalStorage for expanded state persistence
- Responsive design for mobile
- Accessibility (ARIA labels, keyboard nav)

## Next Steps

1. Create Stimulus controller for tree interactions
2. Build recursive tree view partial
3. Update documents index to use tree layout
4. Add CSS for tree styling
5. Implement add folder/file functionality
6. Add file selection and content loading
7. Test across browsers and devices

## References

- Existing UI patterns in `.kiro/steering/ui-patterns.md`
- Current folder/document structure in controllers
- Folder model with parent/child relationships