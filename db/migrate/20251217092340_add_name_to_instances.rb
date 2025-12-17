class AddNameToInstances < ActiveRecord::Migration[8.1]
  def change
    add_column :instances, :name, :string, null: false
    add_index :instances, :name, unique: true
  end
end
