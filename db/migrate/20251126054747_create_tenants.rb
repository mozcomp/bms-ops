class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :code
      t.string :name
      t.json :configuration

      t.timestamps
    end
  end
end
