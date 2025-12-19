# BMS Ops UI Design Patterns

This document defines the UI patterns and conventions used throughout the BMS Ops application. Follow these patterns to ensure consistency across all views.

## Layout Structure

### Page Container
All pages use a consistent layout structure:
```erb
<div class="min-h-screen bg-slate-50 dark:bg-slate-900">
  <%= render "shared/sidebar" %>
  
  <div class="lg:ml-64">
    <%= render "shared/topbar" %>
    
    <main class="p-6">
      <!-- Page content here -->
    </main>
  </div>
</div>
```

### Page Header Pattern
Every page should have a header with title, description, and primary action:
```erb
<div class="flex items-center justify-between mb-6">
  <div>
    <h1 class="text-2xl font-bold text-slate-800 dark:text-slate-100 mb-2">Page Title</h1>
    <p class="text-slate-600 dark:text-slate-400">Page description</p>
  </div>
  <%= link_to new_resource_path, class: "btn btn-primary flex items-center gap-2" do %>
    <%= icon "plus", class: "size-5" %>
    <span>New Resource</span>
  <% end %>
</div>
```

## Color Palette

### Background Colors
- Page background: `bg-slate-50 dark:bg-slate-900`
- Card background: `bg-white dark:bg-slate-800`
- Hover states: `hover:bg-slate-50 dark:hover:bg-slate-700/50`
- Input backgrounds: `bg-slate-50 dark:bg-slate-900`

### Text Colors
- Primary text: `text-slate-900 dark:text-slate-100`
- Secondary text: `text-slate-600 dark:text-slate-400`
- Muted text: `text-slate-500 dark:text-slate-400`
- Link text: `text-primary-600 dark:text-primary-400`

### Border Colors
- Default borders: `border-slate-200 dark:border-slate-700`
- Focus borders: `focus:border-primary-500`

### Status Colors
- Success: `text-green-600 dark:text-green-400`, `bg-green-100 dark:bg-green-900/30`
- Error: `text-red-600 dark:text-red-400`, `bg-red-50 dark:bg-red-900/20`
- Warning: `text-yellow-600 dark:text-yellow-400`, `bg-yellow-100 dark:bg-yellow-900/30`
- Info: `text-blue-600 dark:text-blue-400`, `bg-blue-100 dark:bg-blue-900/30`
- Primary: `text-primary-600 dark:text-primary-400`, `bg-primary-100 dark:bg-primary-900/30`

## Card Components

### Standard Card
```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700">
  <div class="px-6 py-4 border-b border-slate-200 dark:border-slate-700">
    <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">Card Title</h2>
  </div>
  <div class="px-6 py-4">
    <!-- Card content -->
  </div>
</div>
```

### Stat Card (Dashboard)
```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow p-6 border border-slate-200 dark:border-slate-700">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm font-medium text-slate-600 dark:text-slate-400">Metric Name</p>
      <p class="text-3xl font-bold text-slate-900 dark:text-slate-100 mt-2">42</p>
    </div>
    <div class="bg-primary-100 dark:bg-primary-900/30 rounded-full p-3">
      <%= icon "icon-name", class: "size-6 text-primary-600 dark:text-primary-400" %>
    </div>
  </div>
  <p class="text-sm text-green-600 dark:text-green-400 mt-4">+3 this month</p>
</div>
```

### Grid Card (Apps Index)
```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700 overflow-hidden hover:shadow-lg transition">
  <div class="p-6">
    <div class="flex items-start justify-between mb-4">
      <div class="flex items-center gap-3 min-w-0 flex-1">
        <div class="size-12 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center flex-shrink-0">
          <%= icon "code-bracket", class: "size-6 text-blue-600 dark:text-blue-400" %>
        </div>
        <div class="min-w-0 flex-1">
          <h3 class="text-lg font-semibold text-slate-900 dark:text-slate-100 truncate">
            Card Title
          </h3>
        </div>
      </div>
    </div>
    <!-- Card content -->
  </div>
</div>
```

## Table Pattern

### Index Table
```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700 overflow-hidden">
  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-slate-200 dark:divide-slate-700">
      <thead class="bg-slate-50 dark:bg-slate-900">
        <tr>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">
            Column Name
          </th>
        </tr>
      </thead>
      <tbody class="bg-white dark:bg-slate-800 divide-y divide-slate-200 dark:divide-slate-700">
        <tr class="hover:bg-slate-50 dark:hover:bg-slate-700/50 transition">
          <td class="px-6 py-4 whitespace-nowrap">
            <!-- Cell content -->
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
```

### Table Actions Column
```erb
<td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
  <div class="flex items-center justify-end gap-2">
    <%= link_to resource, class: "text-primary-600 dark:text-primary-400 hover:text-primary-900 dark:hover:text-primary-300" do %>
      <%= icon "eye", class: "size-5" %>
    <% end %>
    <%= link_to edit_resource_path(resource), class: "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100" do %>
      <%= icon "pencil", class: "size-5" %>
    <% end %>
    <%= button_to resource, method: :delete, data: { turbo_confirm: "Are you sure?" }, class: "text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300" do %>
      <%= icon "trash", class: "size-5" %>
    <% end %>
  </div>
</td>
```

## Empty States

### Empty State Pattern
```erb
<div class="text-center py-12">
  <div class="inline-flex items-center justify-center size-16 bg-slate-100 dark:bg-slate-700 rounded-full mb-4">
    <%= icon "icon-name", class: "size-8 text-slate-400" %>
  </div>
  <h3 class="text-lg font-medium text-slate-900 dark:text-slate-100 mb-2">No items yet</h3>
  <p class="text-slate-600 dark:text-slate-400 mb-6">Get started by creating your first item.</p>
  <%= link_to new_resource_path, class: "btn btn-primary inline-flex items-center gap-2" do %>
    <%= icon "plus", class: "size-5" %>
    <span>New Item</span>
  <% end %>
</div>
```

## Form Patterns

### Form Layout - Label on Left
**IMPORTANT:** All forms must use the "label on left" layout pattern for consistency.

```erb
<%= form_with(model: resource, class: "space-y-6") do |form| %>
  <!-- Error messages -->
  <% if resource.errors.any? %>
    <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4">
      <div class="flex items-start gap-3">
        <%= icon "exclamation-circle", class: "size-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" %>
        <div class="flex-1">
          <h3 class="text-sm font-medium text-red-800 dark:text-red-400 mb-2">
            <%= pluralize(resource.errors.count, "error") %> prohibited this from being saved:
          </h3>
          <ul class="list-disc list-inside text-sm text-red-700 dark:text-red-400 space-y-1">
            <% resource.errors.full_messages.each do |message| %>
              <li><%= message %></li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
  <% end %>

  <!-- Form sections -->
  <div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700">
    <div class="px-6 py-4 border-b border-slate-200 dark:border-slate-700">
      <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">Section Title</h2>
      <p class="text-sm text-slate-600 dark:text-slate-400 mt-1">Section description</p>
    </div>
    <div class="px-6 py-6 space-y-6">
      <!-- Form fields using label-on-left pattern -->
    </div>
  </div>

  <!-- Form actions -->
  <div class="flex items-center justify-end gap-3">
    <%= link_to "Cancel", resource.persisted? ? resource : resources_path, class: "btn btn-white" %>
    <%= form.submit class: "btn btn-primary" %>
  </div>
<% end %>
```

### Form Field - Label on Left Pattern
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <%= form.label :field_name, class: "block text-sm font-medium text-slate-700 dark:text-slate-300" %>
  </div>
  <div class="flex-1 min-w-0">
    <%= form.text_field :field_name, class: "form-input w-full rounded-lg border-slate-300 dark:border-slate-600 dark:bg-slate-700 dark:text-slate-100 focus:border-primary-500 focus:ring-primary-500", placeholder: "Placeholder text" %>
    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">Helper text</p>
  </div>
</div>
```

### Select Field - Label on Left Pattern
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <%= form.label :field_name, class: "block text-sm font-medium text-slate-700 dark:text-slate-300" %>
  </div>
  <div class="flex-1 min-w-0">
    <%= form.select :field_name, options, {}, class: "form-select w-full rounded-lg border-slate-300 dark:border-slate-600 dark:bg-slate-700 dark:text-slate-100 focus:border-primary-500 focus:ring-primary-500" %>
  </div>
</div>
```

### Textarea Field - Label on Left Pattern
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <%= form.label :field_name, class: "block text-sm font-medium text-slate-700 dark:text-slate-300" %>
  </div>
  <div class="flex-1 min-w-0">
    <%= form.text_area :field_name, rows: 4, class: "form-textarea w-full rounded-lg border-slate-300 dark:border-slate-600 dark:bg-slate-700 dark:text-slate-100 focus:border-primary-500 focus:ring-primary-500", placeholder: "Placeholder text" %>
    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">Helper text</p>
  </div>
</div>
```

### Checkbox Field - Label on Left Pattern
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <span class="block text-sm font-medium text-slate-700 dark:text-slate-300">Field Label</span>
  </div>
  <div class="flex-1 min-w-0">
    <div class="flex items-center">
      <%= form.check_box :field_name, class: "rounded border-slate-300 dark:border-slate-600 text-primary-600 focus:ring-primary-500 dark:bg-slate-700" %>
      <%= form.label :field_name, "Checkbox label text", class: "ml-2 text-sm text-slate-700 dark:text-slate-300" %>
    </div>
    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">Helper text</p>
  </div>
</div>
```

## Show Page Pattern

### Show Page Layout
```erb
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
  <!-- Main content (2/3 width) -->
  <div class="lg:col-span-2 space-y-6">
    <!-- Information cards -->
  </div>

  <!-- Sidebar (1/3 width) -->
  <div class="space-y-6">
    <!-- Metadata card -->
    <!-- Quick actions card -->
  </div>
</div>
```

### Show Page Header
```erb
<div class="flex items-center justify-between mb-6">
  <div class="flex items-center gap-4">
    <%= link_to resources_path, class: "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100" do %>
      <%= icon "arrow-left", class: "size-6" %>
    <% end %>
    <div>
      <h1 class="text-2xl font-bold text-slate-800 dark:text-slate-100 mb-1"><%= resource.name %></h1>
      <p class="text-slate-600 dark:text-slate-400">Resource details</p>
    </div>
  </div>
  <div class="flex items-center gap-2">
    <%= link_to edit_resource_path(resource), class: "btn btn-white flex items-center gap-2" do %>
      <%= icon "pencil", class: "size-5" %>
      <span>Edit</span>
    <% end %>
    <%= button_to resource, method: :delete, data: { turbo_confirm: "Are you sure?" }, class: "btn btn-white text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 flex items-center gap-2" do %>
      <%= icon "trash", class: "size-5" %>
      <span>Delete</span>
    <% end %>
  </div>
</div>
```

### Show Page Information Card - Label on Left Pattern
**IMPORTANT:** All show pages must use the "label on left" layout pattern for consistency with forms.

```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700">
  <div class="px-6 py-4 border-b border-slate-200 dark:border-slate-700">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">Basic Information</h2>
      <!-- Show code field in top right if object has a code field -->
      <% if resource.respond_to?(:code) && resource.code.present? %>
        <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-800 dark:text-primary-400">
          <%= resource.code %>
        </span>
      <% end %>
    </div>
  </div>
  <div class="px-6 py-6 space-y-6">
    <!-- Use label-on-left pattern for all fields -->
    <div class="flex items-start gap-6">
      <div class="w-48 flex-shrink-0">
        <dt class="text-sm font-medium text-slate-500 dark:text-slate-400">Field Label</dt>
      </div>
      <div class="flex-1 min-w-0">
        <dd class="text-sm text-slate-900 dark:text-slate-100">Field Value</dd>
      </div>
    </div>
  </div>
</div>
```

### Show Page Field - Label on Left Pattern
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

### Show Page Field with Link
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <dt class="text-sm font-medium text-slate-500 dark:text-slate-400">Field Label</dt>
  </div>
  <div class="flex-1 min-w-0">
    <dd>
      <%= link_to resource.field_value, resource_path, class: "text-sm text-primary-600 dark:text-primary-400 hover:underline" %>
    </dd>
  </div>
</div>
```

### Show Page Field with Badge
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <dt class="text-sm font-medium text-slate-500 dark:text-slate-400">Status</dt>
  </div>
  <div class="flex-1 min-w-0">
    <dd>
      <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400">
        Active
      </span>
    </dd>
  </div>
</div>
```

### Show Page Field with Code Block
```erb
<div class="flex items-start gap-6">
  <div class="w-48 flex-shrink-0">
    <dt class="text-sm font-medium text-slate-500 dark:text-slate-400">Configuration</dt>
  </div>
  <div class="flex-1 min-w-0">
    <dd class="text-sm text-slate-900 dark:text-slate-100 font-mono bg-slate-50 dark:bg-slate-900 px-3 py-2 rounded">
      <%= resource.configuration %>
    </dd>
  </div>
</div>
```

### Metadata Sidebar
```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700">
  <div class="px-6 py-4 border-b border-slate-200 dark:border-slate-700">
    <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">Metadata</h2>
  </div>
  <div class="px-6 py-4 space-y-4">
    <div>
      <dt class="text-sm font-medium text-slate-500 dark:text-slate-400 mb-1">Created</dt>
      <dd class="text-sm text-slate-900 dark:text-slate-100">
        <%= time_tag resource.created_at, resource.created_at.strftime("%B %d, %Y at %I:%M %p") %>
      </dd>
    </div>
    <div>
      <dt class="text-sm font-medium text-slate-500 dark:text-slate-400 mb-1">Last Updated</dt>
      <dd class="text-sm text-slate-900 dark:text-slate-100">
        <%= time_tag resource.updated_at, resource.updated_at.strftime("%B %d, %Y at %I:%M %p") %>
      </dd>
    </div>
  </div>
</div>
```

### Quick Actions Sidebar
```erb
<div class="bg-white dark:bg-slate-800 rounded-lg shadow border border-slate-200 dark:border-slate-700">
  <div class="px-6 py-4 border-b border-slate-200 dark:border-slate-700">
    <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">Quick Actions</h2>
  </div>
  <div class="px-6 py-4 space-y-2">
    <%= link_to "#", class: "flex items-center gap-3 p-3 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300 transition" do %>
      <%= icon "icon-name", class: "size-5 text-slate-500" %>
      <span class="text-sm font-medium">Action Name</span>
    <% end %>
  </div>
</div>
```

## Button Styles

### Primary Button
```erb
<%= link_to path, class: "btn btn-primary flex items-center gap-2" do %>
  <%= icon "icon-name", class: "size-5" %>
  <span>Button Text</span>
<% end %>
```

### Secondary Button
```erb
<%= link_to path, class: "btn btn-white flex items-center gap-2" do %>
  <%= icon "icon-name", class: "size-5" %>
  <span>Button Text</span>
<% end %>
```

### Destructive Button
```erb
<%= button_to path, method: :delete, data: { turbo_confirm: "Are you sure?" }, class: "btn btn-white text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 flex items-center gap-2" do %>
  <%= icon "trash", class: "size-5" %>
  <span>Delete</span>
<% end %>
```

## Badge/Tag Patterns

### Status Badge
```erb
<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-slate-100 dark:bg-slate-700 text-slate-800 dark:text-slate-300">
  Badge Text
</span>
```

### Primary Badge
```erb
<span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-800 dark:text-primary-400">
  Badge Text
</span>
```

## Icon Usage

### Icon Sizes
- Small icons (inline): `size-4`
- Medium icons (buttons, actions): `size-5`
- Large icons (headers, cards): `size-6`
- Extra large icons (empty states): `size-8`
- Stat card icons: `size-6`
- Avatar icons: `size-10` or `size-12`

### Common Icons
- Add/Create: `plus`
- Edit: `pencil`
- Delete: `trash`
- View: `eye`
- External link: `arrow-top-right-on-square`
- Back: `arrow-left`
- Users/Tenants: `users`
- Services: `server`
- Apps: `code-bracket`
- Databases: `circle-stack`
- Success: `check-circle`
- Error: `exclamation-circle`
- Info: `information-circle`

## Grid Layouts

### Dashboard Stats Grid
```erb
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
  <!-- Stat cards -->
</div>
```

### Two Column Grid
```erb
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
  <!-- Cards -->
</div>
```

### Three Column Grid (Apps)
```erb
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <!-- Cards -->
</div>
```

### Form Grid
```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
  <!-- Form fields -->
</div>
```

## Typography

### Headings
- Page title (h1): `text-2xl font-bold text-slate-800 dark:text-slate-100`
- Section title (h2): `text-lg font-semibold text-slate-900 dark:text-slate-100`
- Card title (h3): `text-lg font-semibold text-slate-900 dark:text-slate-100`

### Body Text
- Primary: `text-sm text-slate-900 dark:text-slate-100`
- Secondary: `text-sm text-slate-600 dark:text-slate-400`
- Muted: `text-sm text-slate-500 dark:text-slate-400`

### Code/Monospace
- Inline code: `font-mono text-sm`
- Code blocks: `font-mono bg-slate-50 dark:bg-slate-900 px-3 py-2 rounded`

## Spacing

### Page Spacing
- Main padding: `p-6`
- Section margin bottom: `mb-6` or `mb-8`
- Card spacing: `space-y-6`

### Card Spacing
- Header padding: `px-6 py-4`
- Content padding: `px-6 py-4` or `px-6 py-6`
- Internal spacing: `space-y-4` or `gap-6`

## Responsive Design

### Breakpoints
- Mobile first approach
- Tablet: `md:` (768px)
- Desktop: `lg:` (1024px)

### Common Responsive Patterns
- Sidebar: `lg:ml-64` (offset for fixed sidebar on desktop)
- Grid columns: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3`
- Form columns: `grid-cols-1 md:grid-cols-2`
- Show page layout: `grid-cols-1 lg:grid-cols-3`

## Flash Messages

Always include flash messages after the page header:
```erb
<%= render "shared/flash_messages" %>
```

## Accessibility

- Use semantic HTML elements
- Include `scope="col"` on table headers
- Use `<dt>` and `<dd>` for definition lists
- Include `sr-only` text for icon-only buttons
- Use `time_tag` helper for dates
- Include proper `aria-label` attributes where needed
- Ensure sufficient color contrast in dark mode

## Animation & Transitions

- Hover transitions: `transition`
- Card hover: `hover:shadow-lg transition`
- Button hover: Built into btn classes
- Row hover: `hover:bg-slate-50 dark:hover:bg-slate-700/50 transition`