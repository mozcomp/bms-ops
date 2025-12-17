class UserDocumentHistory < ApplicationRecord
  belongs_to :user
  belongs_to :document

  validates :visited_at, presence: true
  
  scope :recent, -> { order(visited_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  def self.record_visit(user, document)
    return unless user && document
    
    history = find_or_initialize_by(user: user, document: document)
    history.visited_at = Time.current
    history.save!
  end
end
