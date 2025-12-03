class Tenant < ApplicationRecord
  has_many :instances, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  after_initialize :ensure_configuration
  before_save :ensure_configuration

  # Virtual attribute getters with robust defaults
  def subdomain
    config = configuration || {}
    config["subdomain"] || config[:subdomain] || code
  end

  def subdomain=(value)
    self.configuration ||= {}
    configuration["subdomain"] = value
  end

  def database
    config = configuration || {}
    config["database"] || config[:database] || "bms_#{code}_production"
  end

  def database=(value)
    self.configuration ||= {}
    configuration["database"] = value
  end

  def service_name
    config = configuration || {}
    config["service_name"] || config[:service_name]
  end

  def service_name=(value)
    self.configuration ||= {}
    configuration["service_name"] = value
  end

  def ses_region
    config = configuration || {}
    config["ses_region"] || config[:ses_region] || "ap-southeast-2"
  end

  def ses_region=(value)
    self.configuration ||= {}
    configuration["ses_region"] = value
  end

  def s3_bucket
    config = configuration || {}
    config["s3_bucket"] || config[:s3_bucket] || "bms-#{code}-production"
  end

  def s3_bucket=(value)
    self.configuration ||= {}
    configuration["s3_bucket"] = value
  end

  # Computed URL based on subdomain
  def url
    "https://#{subdomain}.bmserp.com"
  end

  private

  def ensure_configuration
    self.configuration ||= {}
  end
end
