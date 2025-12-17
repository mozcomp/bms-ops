class CreateUserBookmarks < ActiveRecord::Migration[8.1]
  def change
    create_table :user_bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.datetime :bookmarked_at, null: false

      t.timestamps
    end
    
    add_index :user_bookmarks, [:user_id, :document_id], unique: true
    add_index :user_bookmarks, [:user_id, :bookmarked_at]
  end
end
