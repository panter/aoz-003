class DropVolunteerEmails < ActiveRecord::Migration[5.1]
  def change
    drop_table :volunteer_emails
  end
end
