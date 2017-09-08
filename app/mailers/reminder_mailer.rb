class ReminderMailer < ApplicationMailer
  def reminder_email(volunteer, reminder, volunteer_email)
    @volunteer = volunteer
    @reminder = reminder
    mail(to: volunteer_email, subject: t('.subject'))
  end
end
