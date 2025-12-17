class HealthCheck < ApplicationRecord
  validates :name, :status, :checked_at, presence: true
  validates :status, inclusion: { in: %w[healthy unhealthy unknown] }
  validates :name, uniqueness: { scope: :checked_at }

  scope :current, -> { where('checked_at > ?', 5.minutes.ago) }
  scope :unhealthy, -> { where(status: 'unhealthy') }
  scope :by_name, ->(name) { where(name: name) }
  scope :recent, ->(hours = 24) { where('checked_at > ?', hours.hours.ago) }

  def healthy?
    status == 'healthy'
  end

  def unhealthy?
    status == 'unhealthy'
  end

  def unknown?
    status == 'unknown'
  end
end
