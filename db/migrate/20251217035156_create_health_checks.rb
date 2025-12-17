class CreateHealthChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :health_checks do |t|
      t.string :name, null: false
      t.string :status, null: false
      t.datetime :checked_at, null: false
      t.json :details

      t.timestamps
    end

    add_index :health_checks, :name
    add_index :health_checks, :status
    add_index :health_checks, :checked_at
    add_index :health_checks, [:name, :checked_at]
  end
end
