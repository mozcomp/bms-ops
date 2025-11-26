class CreateApps < ActiveRecord::Migration[8.1]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :repository

      t.timestamps
    end
  end
end
