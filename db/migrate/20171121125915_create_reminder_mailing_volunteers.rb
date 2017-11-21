class CreateReminderMailingVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :reminder_mailing_volunteers do |t|
      t.belongs_to :volunteer
      t.belongs_to :reminder_mailing
      t.references :reminder_mailable, polymorphic: true, index: { name: 'reminder_mailable_index' }
      t.integer :link_visits, default: 0
      t.boolean :confirmed_form, default: false

      t.timestamps
    end
  end
end
