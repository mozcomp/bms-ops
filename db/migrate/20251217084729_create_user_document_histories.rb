class CreateUserDocumentHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :user_document_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.datetime :visited_at, null: false

      t.timestamps
    end
    
    add_index :user_document_histories, [:user_id, :visited_at]
    add_index :user_document_histories, [:user_id, :document_id], unique: true
  end
end
