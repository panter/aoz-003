class CreateReminders < ActiveRecord::Migration[5.1]
  def change
    create_table :reminders do |t|
      t.date :sent_at
      t.belongs_to :assignment
      t.belongs_to :volunteer
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
