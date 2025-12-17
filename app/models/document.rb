class Document < ApplicationRecord
  belongs_to :folder, optional: true
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  has_many :document_versions, dependent: :destroy
  has_one_attached :content_file
  has_many_attached :attachments
  has_many :user_document_histories, dependent: :destroy
  has_many :user_bookmarks, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: { scope: :folder_id }, length: { maximum: 255 }
  validates :content, presence: true
  validates :visibility, presence: true, inclusion: { in: %w[public private admin_only] }
  
  # File upload validations
  validate :validate_attachment_types
  validate :validate_attachment_sizes

  scope :published, -> { where(published: true) }
  scope :in_folder, ->(folder) { where(folder: folder) }
  scope :public_documents, -> { where(visibility: 'public') }
  scope :private_documents, -> { where(visibility: 'private') }
  scope :admin_only_documents, -> { where(visibility: 'admin_only') }
  
  # Scope for filtering documents based on user permissions
  scope :visible_to, ->(user) {
    if user&.admin?
      all # Admins can see everything
    else
      where(visibility: ['public', 'private']) # Regular users can see public and private
    end
  }

  before_validation :generate_slug, if: -> { title.present? && slug.blank? }
  after_update :create_version_if_content_changed

  # Generate markdown reference for an attachment
  def attachment_markdown_reference(attachment)
    url = Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true)
    filename = attachment.filename.to_s
    
    if attachment.image?
      "![#{filename}](#{url})"
    else
      "[#{filename}](#{url})"
    end
  end
  
  # Get all attachment markdown references
  def attachment_references
    attachments.map { |attachment| attachment_markdown_reference(attachment) }
  end
  
  # Visibility helper methods
  def public?
    visibility == 'public'
  end
  
  def private?
    visibility == 'private'
  end
  
  def admin_only?
    visibility == 'admin_only'
  end
  
  def visible_to?(user)
    return true if user&.admin? # Admins can see everything
    return false if admin_only? # Non-admins can't see admin-only documents
    true # Public and private documents are visible to all authenticated users
  end

  private

  def generate_slug
    return if title.blank?
    
    base_slug = title.parameterize
    candidate_slug = base_slug
    counter = 1
    
    while Document.where(folder: folder).where.not(id: id).exists?(slug: candidate_slug)
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = candidate_slug
  end

  def create_version_if_content_changed
    return unless saved_change_to_content?
    
    # Get the next version number
    next_version = document_versions.maximum(:version_number).to_i + 1
    
    # Create a new version with the previous content
    document_versions.create!(
      content: content_before_last_save,
      version_number: next_version,
      created_by: updated_by,
      change_summary: "Content updated"
    )
  end
  
  def validate_attachment_types
    return unless attachments.attached?
    
    allowed_types = %w[
      image/jpeg image/jpg image/png image/gif image/webp image/svg+xml
      application/pdf
      text/plain text/markdown text/csv
      application/json application/xml
      application/zip application/x-zip-compressed
      application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    ]
    
    attachments.each do |attachment|
      unless allowed_types.include?(attachment.content_type)
        errors.add(:attachments, "#{attachment.filename} has an unsupported file type")
      end
    end
  end
  
  def validate_attachment_sizes
    return unless attachments.attached?
    
    max_size = 10.megabytes
    
    attachments.each do |attachment|
      if attachment.byte_size > max_size
        errors.add(:attachments, "#{attachment.filename} is too large (maximum is #{max_size / 1.megabyte}MB)")
      end
    end
  end
end