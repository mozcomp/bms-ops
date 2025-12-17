class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.string :title, null: false, limit: 255
      t.string :slug, null: false, limit: 255
      t.text :content, null: false
      t.text :excerpt
      t.boolean :published, default: false
      t.references :folder, null: true, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :documents, [:slug, :folder_id], unique: true
    add_index :documents, :published
  end
end
