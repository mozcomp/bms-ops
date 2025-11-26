class Tenant < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  before_save :ensure_configuration

  def subdomain
    configuration.try(:[], :subdomain) || code
  end

  def subdomain=(value)
    self.configuration ||= {}
    configuration[:subdomain] = value
  end

  def database
    configuration.try(:[], :database) || "bms_#{code}_production"
  end

  def database=(value)
    self.configuration ||= {}
    configuration[:database] = value
  end

  def service_name
    configuration.try(:[], :service_name)
  end

  def service_name=(value)
    self.configuration ||= {}
    configuration[:service_name] = value
  end

  def ses_region
    configuration.try(:[], :ses_region) || "ap-southeast-2"
  end

  def ses_region=(value)
    self.configuration ||= {}
    configuration[:ses_region] = value
  end

  def s3_bucket
    configuration.try(:[], :s3_bucket) || "bms-#{code}-production"
  end

  def s3_bucket=(value)
    self.configuration ||= {}
    configuration[:s3_bucket] = value
  end

  def url
    "https://#{subdomain}.bmserp.com"
  end

  private

  def ensure_configuration
    self.configuration ||= {}
  end
end
