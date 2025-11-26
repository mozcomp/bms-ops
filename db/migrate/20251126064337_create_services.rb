class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name
      t.string :image
      t.string :registry
      t.string :version
      t.json :task_definitions
      t.json :service_definition
      t.string :service_task
      t.string :string
      t.json :environment

      t.timestamps
    end
  end
end
