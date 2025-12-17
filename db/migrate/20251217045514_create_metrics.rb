class CreateMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :metrics do |t|
      t.string :name, null: false
      t.decimal :value, precision: 15, scale: 6, null: false
      t.datetime :timestamp, null: false
      t.json :tags, default: {}
      t.string :aggregation_period

      t.timestamps
    end

    # Compound indexes for efficient time-series querying
    add_index :metrics, [:name, :timestamp], name: "index_metrics_on_name_and_timestamp"
    add_index :metrics, :timestamp, name: "index_metrics_on_timestamp"
    add_index :metrics, :name, name: "index_metrics_on_name"
    add_index :metrics, [:aggregation_period, :timestamp], name: "index_metrics_on_aggregation_period_and_timestamp"
  end
end
