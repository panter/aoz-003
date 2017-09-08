class ReminderMailer < ApplicationMailer
  def reminder_email(volunteer, volunteer_email)
    @volunteer = volunteer
    mail(to: volunteer_email, subject: 'Reminder')
  end
end
