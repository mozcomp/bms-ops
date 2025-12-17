class CreateDocumentVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :document_versions do |t|
      t.references :document, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :version_number, null: false
      t.text :change_summary
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :document_versions, [:document_id, :version_number], unique: true
  end
end
