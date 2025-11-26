class CreateIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.string :uid
      t.text :access_token
      t.time :token_expires
      t.text :refresh_token

      t.timestamps
    end
  end
end
