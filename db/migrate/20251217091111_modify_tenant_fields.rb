class ModifyTenantFields < ActiveRecord::Migration[8.1]
  def change
    remove_column :tenants, :configuration, :json
    add_column :tenants, :contact, :string
    add_column :tenants, :contact_details, :json
  end
end
