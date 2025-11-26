class Database < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  before_save :ensure_connection

  # Virtual attribute for JSON field editing
  def connection_json
    connection.to_json if connection.present?
  end

  def connection_json=(value)
    self.connection = value.present? ? JSON.parse(value) : {}
  rescue JSON::ParserError
    self.connection = {}
  end

  # Helper methods for connection details
  def host
    connection&.dig("host") || "localhost"
  end

  def port
    connection&.dig("port") || 5432
  end

  def database_name
    connection&.dig("database") || name
  end

  def username
    connection&.dig("username")
  end

  def adapter
    connection&.dig("adapter") || "postgresql"
  end

  # Build connection string for display
  def connection_string
    if connection.present?
      "#{adapter}://#{username}@#{host}:#{port}/#{database_name}"
    else
      "Not configured"
    end
  end

  # Status indicator
  def status
    # In real implementation, this would check actual connection
    connection.present? ? "Configured" : "Not Configured"
  end

  def status_color
    connection.present? ? "green" : "yellow"
  end

  private

  def ensure_connection
    self.connection ||= {}
  end
end
