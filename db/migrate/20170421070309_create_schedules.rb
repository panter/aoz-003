class CreateSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :schedules do |t|
      t.references :client, foreign_key: true
      t.string :day
      t.string :time
      t.boolean :available, default: false

      t.timestamps
    end
  end
end
