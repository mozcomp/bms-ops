# BMS Ops - AI Coding Agent Instructions

## Project Overview
Rails 8.1 application for BMS operations using **Rails UI** (Hound theme) for pre-built UI components. This is a modern Rails app leveraging Hotwire (Turbo + Stimulus), Propshaft for assets, importmap for JS, and Tailwind CSS via the new `@import "tailwindcss"` syntax.

**Key Architecture**: Rails UI theme integration (`railsui` gem ~3.3) with dynamic page generation via metaprogramming in `Rui::PagesController`.

## Critical Dependencies & Stack
- **Rails 8.1** with modern defaults (Solid Cache, Solid Queue, Solid Cable for SQLite-backed adapters)
- **Rails UI (Hound theme)**: Pre-built components and pages under `app/views/rui/` and `Railsui` namespace
- **Hotwire**: Turbo Rails + Stimulus for SPA-like interactions (no traditional JS framework)
- **Tailwind CSS**: Configured via `app/assets/tailwind/application.css` with `@import "tailwindcss"` (not tailwindcss-rails gem)
- **Propshaft**: Asset pipeline (not Sprockets) - see `app/assets/builds/tailwind.css` for compiled output
- **Importmap**: JS dependencies loaded via CDN (see `config/importmap.rb`), includes Rails UI Stimulus controllers
- **SQLite3**: Database for Active Record, cache, queue, and cable (Solid adapters)
- **Kamal**: Deployment configuration in `config/deploy.yml` for Docker-based deployments

## Development Workflow

### Starting Development Server
```bash
bin/setup              # First-time setup: installs deps, preps DB, starts server
bin/dev                # Starts both Rails server (port 3000) and Tailwind watcher
```
`Procfile.dev` runs two processes: `bin/rails server` and `bin/rails tailwindcss:watch`. Uses foreman/overmind.

### Running Tests & CI
```bash
bin/rails test         # Run unit tests
bin/rails test:system  # Run system tests (Capybara + Selenium)
bin/ci                 # Full CI pipeline: style checks, security audits, tests
```

**CI Pipeline** (`config/ci.rb` via `bin/ci`):
1. RuboCop style checks (`bin/rubocop`)
2. Security: Bundler Audit, Importmap audit, Brakeman static analysis
3. Rails unit tests + system tests
4. DB seed test (`RAILS_ENV=test bin/rails db:seed:replant`)

### Security & Code Quality
- **RuboCop**: Rails Omakase style guide enforced (`rubocop-rails-omakase`)
- **Brakeman**: Security scanner for vulnerabilities
- **Bundler Audit**: Checks gems for known CVEs (config: `config/bundler-audit.yml`)

## Rails UI Integration Pattern

### Dynamic Route & Controller Generation
Routes are defined in `config/routes.rb` under `namespace :rui` but controllers are **metaprogrammed**:

```ruby
# app/controllers/rui/pages_controller.rb
class Rui::PagesController < ApplicationController
  Railsui.config.pages.each do |page|
    define_method(page.to_sym) do
      render "rui/pages/#{page}", layout: determine_layout(page)
    end
  end
end
```

**Pages configured** in `config/railsui.yml`:
- `about`, `pricing`, `dashboard`, `projects`, `project`, `messages`, etc.
- Each page auto-generates a controller action and renders view from `app/views/rui/pages/`

### Adding New Rails UI Pages
1. Add page name to `config/railsui.yml` under `pages:` array
2. Add route in `config/routes.rb` under `namespace :rui`
3. Rails UI will auto-generate controller method; views should exist in `app/views/rui/pages/`

### Styling & Theming
- **Theme**: Hound (`theme: hound` in `config/railsui.yml`)
- **Body classes**: Defined in `config/railsui.yml` for dark mode support
- **Custom styles**: `app/assets/tailwind/application.css` imports Rails UI stylesheets from `app/assets/stylesheets/railsui/`
- **Tailwind config**: `app/assets/stylesheets/railsui/tailwind.config.js` includes Rails UI gem paths for content scanning

## Asset Pipeline (Propshaft + Importmap)

### CSS/Tailwind
- **Source**: `app/assets/tailwind/application.css` (uses `@import "tailwindcss"`)
- **Compiled**: `app/assets/builds/tailwind.css` (watched by `bin/rails tailwindcss:watch`)
- **Layout link**: `stylesheet_link_tag :app` in `app/views/layouts/application.html.erb`

### JavaScript (Importmap)
- **Entry point**: `app/javascript/application.js`
- **Dependencies**: Pinned in `config/importmap.rb` (Turbo, Stimulus, Trix, ActionText, Rails UI Stimulus)
- **External packages**: Loaded via ESM from unpkg.com/esm.sh (tippy.js, flatpickr, apexcharts, photoswipe, etc.)
- **Custom controllers**: `app/javascript/controllers/` auto-loaded by Stimulus

## Database & Background Jobs

### Solid Queue (Background Jobs)
- **Runs in-process**: `SOLID_QUEUE_IN_PUMA: true` in `config/deploy.yml` for single-server deployments
- **Recurring jobs**: Configured in `config/recurring.yml` (e.g., cleanup jobs every hour)
- **Production job**: `SolidQueue::Job.clear_finished_in_batches` runs hourly at minute 12

### Database
- **SQLite3** for all environments (development, test, production)
- **Schemas**: Separate schemas for cable (`cable_schema.rb`), cache (`cache_schema.rb`), queue (`queue_schema.rb`), main (`schema.rb`)
- **Migrations**: Standard Rails migrations in `db/migrate/`

## Deployment (Kamal)

### Configuration (`config/deploy.yml`)
- **Service**: `bms_ops` Docker image
- **Registry**: `localhost:5555` (update for production: Docker Hub, GHCR, etc.)
- **Servers**: Web server at `192.168.0.1` (placeholder - update for real deployment)
- **Volumes**: `bms_ops_storage:/rails/storage` for SQLite DB and Active Storage
- **Secrets**: `RAILS_MASTER_KEY` injected from `.kamal/secrets`

### Kamal Commands
```bash
bin/kamal console      # Interactive Rails console on server
bin/kamal shell        # SSH into running container
bin/kamal logs         # Tail application logs
bin/kamal dbc          # Database console on server
```

## Code Conventions

### Controllers
- Inherit from `ApplicationController` (modern browser enforcement, importmap etag invalidation)
- Use `allow_browser versions: :modern` to block legacy browsers
- Rails UI pages use dynamic method generation pattern (see `Rui::PagesController`)

### Views
- **Layouts**: `app/views/layouts/application.html.erb` includes `railsui_head` and `railsui_launcher` helpers
- **Rails UI helpers**: Use `railsui_head` for meta tags and `railsui_launcher` (dev only) for component library access
- **Turbo frames**: Prefer Turbo for dynamic updates over JavaScript

### JavaScript
- **Stimulus controllers**: Place in `app/javascript/controllers/`, follow Rails UI patterns in `app/javascript/controllers/railsui/`
- **Importmap**: Pin external libraries via `bin/importmap pin <package>` or manually in `config/importmap.rb`

## Important Files to Reference
- `config/railsui.yml`: Theme config, page list, body classes
- `config/deploy.yml`: Kamal deployment settings
- `config/ci.rb`: CI pipeline steps
- `app/controllers/rui/pages_controller.rb`: Metaprogramming pattern example
- `app/assets/tailwind/application.css`: Tailwind entry point with Rails UI imports
- `Procfile.dev`: Development processes (Rails + Tailwind watch)
