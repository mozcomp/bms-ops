class Metric < ApplicationRecord
  validates :name, :value, :timestamp, presence: true
  validates :value, numericality: true
  validates :name, length: { maximum: 255 }
  validates :aggregation_period, inclusion: { in: %w[raw minute hour day], allow_nil: true }

  # Scopes for querying time-series data
  scope :by_name, ->(name) { where(name: name) }
  scope :time_range, ->(start_time, end_time) { where(timestamp: start_time..end_time) }
  scope :recent, ->(hours = 24) { where('timestamp > ?', hours.hours.ago) }
  scope :aggregated, -> { where.not(aggregation_period: [nil, 'raw']) }
  scope :raw_data, -> { where(aggregation_period: [nil, 'raw']) }

  # Time-series aggregation methods
  def self.aggregate_by_minute(name, start_time, end_time)
    where(name: name, timestamp: start_time..end_time)
      .group("strftime('%Y-%m-%d %H:%M', timestamp)")
      .average(:value)
  end

  def self.aggregate_by_hour(name, start_time, end_time)
    where(name: name, timestamp: start_time..end_time)
      .group("strftime('%Y-%m-%d %H', timestamp)")
      .average(:value)
  end

  def self.aggregate_by_day(name, start_time, end_time)
    where(name: name, timestamp: start_time..end_time)
      .group("strftime('%Y-%m-%d', timestamp)")
      .average(:value)
  end

  # Get latest value for a metric
  def self.latest_value(name)
    by_name(name).order(timestamp: :desc).limit(1).pluck(:value).first
  end

  # Get metrics summary for dashboard
  def self.summary_for_dashboard(hours = 24)
    recent(hours)
      .group(:name)
      .group_by(&:name)
      .transform_values do |metrics|
        values = metrics.map(&:value)
        {
          count: values.size,
          avg: values.sum / values.size.to_f,
          min: values.min,
          max: values.max,
          latest: metrics.max_by(&:timestamp)&.value
        }
      end
  end

  # Tag helper methods
  def tag(key)
    tags&.dig(key.to_s)
  end

  def add_tag(key, value)
    self.tags = (tags || {}).merge(key.to_s => value)
  end

  def remove_tag(key)
    return unless tags
    self.tags = tags.except(key.to_s)
  end

  # Formatting helpers
  def formatted_value
    case name
    when /time|duration|latency/
      "#{value.round(2)}ms"
    when /cpu|memory|disk/
      "#{value.round(1)}%"
    when /count|requests/
      value.to_i.to_s
    else
      value.to_s
    end
  end

  def formatted_timestamp
    timestamp.strftime('%Y-%m-%d %H:%M:%S')
  end
end