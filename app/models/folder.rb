class Folder < ApplicationRecord
  belongs_to :parent, class_name: 'Folder', optional: true
  has_many :children, class_name: 'Folder', foreign_key: 'parent_id', dependent: :destroy
  has_many :documents, dependent: :destroy
  belongs_to :created_by, class_name: 'User'

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: { scope: :parent_id }, length: { maximum: 255 }

  scope :root_folders, -> { where(parent_id: nil) }

  before_validation :generate_slug, if: -> { name.present? && slug.blank? }
  validate :prevent_circular_references

  def ancestors
    return [] unless parent
    parent.ancestors + [parent]
  end

  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end

  def descendant_ids
    descendants.map(&:id)
  end

  def root?
    parent_id.nil?
  end

  def leaf?
    children.empty?
  end

  def path
    ancestors.map(&:name) + [name]
  end

  def full_path
    path.join(' / ')
  end

  private

  def generate_slug
    return if name.blank?
    
    base_slug = name.parameterize
    candidate_slug = base_slug
    counter = 1
    
    while Folder.where(parent: parent).where.not(id: id).exists?(slug: candidate_slug)
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = candidate_slug
  end

  def prevent_circular_references
    return unless parent_id.present?
    
    if parent_id == id
      errors.add(:parent, "cannot be the same as the folder itself")
      return
    end
    
    # Check if the parent is a descendant of this folder
    current_parent = parent
    while current_parent
      if current_parent.id == id
        errors.add(:parent, "cannot be a descendant of this folder")
        break
      end
      current_parent = current_parent.parent
    end
  end
end