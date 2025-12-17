class AddVisibilityToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :visibility, :string, default: 'public', null: false
    add_index :documents, :visibility
  end
end
