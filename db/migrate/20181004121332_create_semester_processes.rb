class CreateSemesterProcesses < ActiveRecord::Migration[5.1]
  def change
    create_table :semester_processes do |t|
      t.references :creator, references: :users, index: true
      t.datetime :period_start
      t.datetime :period_end

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
