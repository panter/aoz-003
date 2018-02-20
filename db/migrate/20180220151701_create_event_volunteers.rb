class CreateEventVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :event_volunteers do |t|
      t.belongs_to  :volunteer
      t.belongs_to  :event
      t.boolean     :picked, default: false

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
