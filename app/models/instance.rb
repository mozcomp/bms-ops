class Instance < ApplicationRecord
  belongs_to :tenant
  belongs_to :app
  belongs_to :service

  validates :tenant_id, presence: true
  validates :app_id, presence: true
  validates :service_id, presence: true
  validates :environment, presence: true, inclusion: { in: %w[production staging development] }
  validates :virtual_host, presence: true
  validates :tenant_id, uniqueness: { scope: [:app_id, :environment], message: "already has an instance for this app in this environment" }

  before_validation :set_default_virtual_host, on: :create
  before_save :ensure_env_vars

  # Virtual attributes for JSON field editing
  def env_vars_json
    env_vars.to_json if env_vars.present?
  end

  def env_vars_json=(value)
    self.env_vars = value.present? ? JSON.parse(value) : {}
  rescue JSON::ParserError
    self.env_vars = {}
  end

  # Returns human-readable environment name
  def environment_label
    environment&.capitalize
  end

  # Returns complete URL with protocol
  def full_url
    return nil unless virtual_host.present?
    "https://#{virtual_host}"
  end

  private

  def set_default_virtual_host
    return if virtual_host.present?
    return unless tenant.present?

    subdomain = tenant.subdomain
    subdomain = "#{environment}-#{subdomain}" unless environment == 'production'
    self.virtual_host = "#{subdomain}.bmserp.com"
  end

  def ensure_env_vars
    self.env_vars ||= {}
  end
end
