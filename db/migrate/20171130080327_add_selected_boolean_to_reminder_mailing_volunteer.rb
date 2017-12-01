class AddSelectedBooleanToReminderMailingVolunteer < ActiveRecord::Migration[5.1]
  def change
    change_table :reminder_mailing_volunteers do |t|
      t.boolean :picked, default: false
    end
  end
end
