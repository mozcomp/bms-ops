class DocumentVersion < ApplicationRecord
  belongs_to :document
  belongs_to :created_by, class_name: 'User'

  validates :content, presence: true
  validates :version_number, presence: true, uniqueness: { scope: :document_id }

  scope :ordered, -> { order(:version_number) }
  scope :recent, -> { order(created_at: :desc) }

  def previous_version
    document.document_versions
            .where('version_number < ?', version_number)
            .order(version_number: :desc)
            .first
  end

  def next_version
    document.document_versions
            .where('version_number > ?', version_number)
            .order(:version_number)
            .first
  end

  def is_latest?
    document.document_versions.maximum(:version_number) == version_number
  end

  def author_name
    created_by&.first_name || created_by&.email_address || 'Unknown'
  end
end