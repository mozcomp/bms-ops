class AddSearchIndexesToDocuments < ActiveRecord::Migration[8.1]
  def change
    # Add indexes for search performance
    add_index :documents, :title
    add_index :documents, :content, length: 255  # Partial index for content
    add_index :documents, :excerpt
    add_index :documents, :updated_at
    
    # Add composite index for search ranking
    add_index :documents, [:published, :visibility, :updated_at]
    
    # Add indexes for folders search
    add_index :folders, :name
    add_index :folders, :description, length: 255
  end
end
