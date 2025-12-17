class Tenant < ApplicationRecord
  has_many :instances, dependent: :destroy

  validates :code, presence: true, uniqueness: { message: "has already been taken. Each tenant must have a unique code." }
  validates :name, presence: true

  after_initialize :ensure_contact_details
  before_save :ensure_contact_details

  # Virtual attribute getters for contact details with robust defaults
  def email
    details = contact_details || {}
    details["email"] || details[:email]
  end

  def email=(value)
    self.contact_details ||= {}
    contact_details["email"] = value
  end

  def phone
    details = contact_details || {}
    details["phone"] || details[:phone]
  end

  def phone=(value)
    self.contact_details ||= {}
    contact_details["phone"] = value
  end

  def address
    details = contact_details || {}
    details["address"] || details[:address]
  end

  def address=(value)
    self.contact_details ||= {}
    contact_details["address"] = value
  end

  def company
    details = contact_details || {}
    details["company"] || details[:company]
  end

  def company=(value)
    self.contact_details ||= {}
    contact_details["company"] = value
  end

  # Computed URL based on code
  def url
    "https://#{code}.bmserp.com"
  end

  private

  def ensure_contact_details
    self.contact_details ||= {}
  end
end
