class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :created_documents, class_name: 'Document', foreign_key: 'created_by_id', dependent: :destroy
  has_many :updated_documents, class_name: 'Document', foreign_key: 'updated_by_id', dependent: :nullify
  has_many :created_folders, class_name: 'Folder', foreign_key: 'created_by_id', dependent: :destroy
  has_many :created_document_versions, class_name: 'DocumentVersion', foreign_key: 'created_by_id', dependent: :destroy
  has_many :user_document_histories, dependent: :destroy
  has_many :user_bookmarks, dependent: :destroy
  has_many :bookmarked_documents, through: :user_bookmarks, source: :document

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    admin == true
  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    else
      email_address
    end
  end

  def recent_documents(limit = 10)
    user_document_histories.recent
                          .includes(document: [:folder, :created_by])
                          .limit(limit)
                          .map(&:document)
  end

  def bookmarked?(document)
    user_bookmarks.exists?(document: document)
  end
end
