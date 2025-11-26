class CreateDatabases < ActiveRecord::Migration[8.1]
  def change
    create_table :databases do |t|
      t.string :name
      t.json :connection
      t.string :schema_version

      t.timestamps
    end
  end
end
