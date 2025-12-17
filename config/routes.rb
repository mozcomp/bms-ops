Rails.application.routes.draw do

  namespace :rui do
    get "about", to: "pages#about"
    get "pricing", to: "pages#pricing"
    get "overview", to: "pages#overview"
    get "apps", to: "pages#apps"
    get "app", to: "pages#app"
    get "app_activity", to: "pages#app_activity"
    get "app_domains", to: "pages#app_domains"
    get "app_access", to: "pages#app_access"
    get "app_settings", to: "pages#app_settings"
    get "servers", to: "pages#servers"
    get "domains", to: "pages#domains"
    get "databases", to: "pages#databases"
    get "deploys", to: "pages#deploys"
    get "users", to: "pages#users"
    get "analytics", to: "pages#analytics"
    get "settings", to: "pages#settings"
    get "empty", to: "pages#empty"
    get "notifications", to: "pages#notifications"
    get "support", to: "pages#support"
    get "changelog", to: "pages#changelog"
    get "changelog_detail", to: "pages#changelog_detail"
    get "privacy_policy", to: "pages#privacy_policy"
    get "terms", to: "pages#terms"
    get "contact", to: "pages#contact"
    get "settings_billing", to: "pages#settings_billing"
    get "settings_notifications", to: "pages#settings_notifications"
    get "settings_team", to: "pages#settings_team"
    get "settings_integrations", to: "pages#settings_integrations"
  end
  resource :session
  resources :passwords, param: :token

  if Rails.env.development?
    # Visit the start page for Rails UI any time at /railsui/start
    mount Railsui::Engine, at: "/railsui"
  end

  # BMS Ops custom dashboard
  root "dashboard#index"

  # Tenant management
  resources :tenants

  # Service management
  resources :services

  # App management
  resources :apps

  # Database management
  resources :databases

  # Instance management
  resources :instances

  # Documentation management
  resources :folders do
    resources :documents, except: [:index]
  end
  resources :documents do #, only: [:index, :show, :edit, :update, :destroy] do
    collection do
      get :search
      get :search_suggestions
      get :recent
      get :bookmarks
    end
    member do
      post :upload_attachment
      get :versions
      get :compare_versions
      post :restore_version
      post :toggle_bookmark
    end
  end

  # Admin interface
  get 'admin', to: 'admin#index'
  get 'admin/users', to: 'admin#users'
  patch 'admin/users/:id/admin', to: 'admin#update_user_admin', as: 'admin_update_user_admin'
  get 'admin/documents', to: 'admin#documents'
  patch 'admin/documents/:id/visibility', to: 'admin#update_document_visibility', as: 'admin_update_document_visibility'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Custom health check endpoints
  get "health" => "health_check#show", as: :health_check
  get "health/detailed" => "health_check#detailed", as: :detailed_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
