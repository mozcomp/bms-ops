class CreateInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :instances do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :app, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :environment, null: false
      t.string :virtual_host, null: false
      t.json :env_vars

      t.timestamps
    end

    add_index :instances, :environment
    add_index :instances, [:tenant_id, :app_id, :environment], unique: true, name: 'index_instances_on_tenant_app_environment'
  end
end
