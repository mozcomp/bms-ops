class Service < ApplicationRecord
  has_many :instances, dependent: :destroy

  validates :name, presence: true, uniqueness: { message: "has already been taken. Each service must have a unique name." }
  validates :image, presence: true

  before_save :ensure_json_fields

  # Virtual attributes for JSON field editing
  def environment_json
    environment.to_json if environment.present?
  end

  def environment_json=(value)
    self.environment = value.present? ? JSON.parse(value) : {}
  rescue JSON::ParserError
    self.environment = {}
  end

  def service_definition_json
    service_definition.to_json if service_definition.present?
  end

  def service_definition_json=(value)
    self.service_definition = value.present? ? JSON.parse(value) : {}
  rescue JSON::ParserError
    self.service_definition = {}
  end

  def task_definitions_json
    task_definitions.to_json if task_definitions.present?
  end

  def task_definitions_json=(value)
    self.task_definitions = value.present? ? JSON.parse(value) : {}
  rescue JSON::ParserError
    self.task_definitions = {}
  end

  def full_image
    if registry.present? && image.present?
      "#{registry}/#{image}:#{version || 'latest'}"
    elsif image.present?
      "#{image}:#{version || 'latest'}"
    else
      "Not configured"
    end
  end

  def status
    # This would be populated from AWS ECS API in real implementation
    "Running"
  end

  private

  def ensure_json_fields
    self.environment ||= {}
    self.service_definition ||= {}
    self.task_definitions ||= {}
  end
end
