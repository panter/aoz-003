class CreateEventVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :event_volunteers do |t|
      t.belongs_to  :volunteer
      t.belongs_to  :event

      t.references  :creator, references: :users, index: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
