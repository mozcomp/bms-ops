class AddNameToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :timezone, :string, default: "UTC", null: false
    add_column :users, :locale, :string, default: "en", null: false
  end
end
