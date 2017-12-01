class AddSelectedBooleanToReminderMailingVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :reminder_mailing_volunteers, :picked, :boolean, default: false
  end
end
