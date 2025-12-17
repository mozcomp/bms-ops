class LogEntry < ApplicationRecord
  validates :timestamp, :level, :message, presence: true
  validates :level, inclusion: { in: %w[debug info warn error fatal] }
  
  scope :by_level, ->(level) { where(level: level) }
  scope :recent, ->(hours = 24) { where('timestamp > ?', hours.hours.ago) }
  scope :for_request, ->(request_id) { where(request_id: request_id) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  
  # Order by timestamp descending by default
  default_scope { order(timestamp: :desc) }
  
  # Convert log entry to structured JSON format
  def to_structured_json
    {
      timestamp: timestamp.iso8601,
      level: level,
      message: message,
      context: context || {},
      request_id: request_id,
      user_id: user_id
    }.compact.to_json
  end
  
  # Class method to create log entry with current timestamp
  def self.create_entry(level, message, context = {})
    create!(
      timestamp: Time.current,
      level: level.to_s,
      message: message,
      context: context
    )
  end
end