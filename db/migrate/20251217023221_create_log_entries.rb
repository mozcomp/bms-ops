class CreateLogEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :log_entries do |t|
      t.datetime :timestamp, null: false
      t.string :level, null: false
      t.text :message, null: false
      t.json :context
      t.string :request_id
      t.integer :user_id

      t.timestamps
    end

    # Add indexes for efficient querying
    add_index :log_entries, :timestamp
    add_index :log_entries, :level
    add_index :log_entries, :request_id
    add_index :log_entries, :user_id
    add_index :log_entries, [:level, :timestamp]
    add_index :log_entries, [:request_id, :timestamp]
  end
end
