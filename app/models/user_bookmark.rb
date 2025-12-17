class UserBookmark < ApplicationRecord
  belongs_to :user
  belongs_to :document

  validates :bookmarked_at, presence: true
  validates :user_id, uniqueness: { scope: :document_id }
  
  scope :recent, -> { order(bookmarked_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  def self.toggle_bookmark(user, document)
    return unless user && document
    
    bookmark = find_by(user: user, document: document)
    if bookmark
      bookmark.destroy!
      false # Removed bookmark
    else
      create!(user: user, document: document, bookmarked_at: Time.current)
      true # Added bookmark
    end
  end
end
