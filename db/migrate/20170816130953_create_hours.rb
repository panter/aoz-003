class CreateHours < ActiveRecord::Migration[5.1]
  def change
    create_table :hours do |t|
      t.date :meeting_date
      t.integer :hours, default: 0
      t.integer :minutes, default: 0
      t.string :activity
      t.string :comments
      t.belongs_to :volunteer
      t.belongs_to :assignment
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
