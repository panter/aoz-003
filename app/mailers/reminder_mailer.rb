class ReminderMailer < ApplicationMailer
  def reminder_email(reminder)
    @volunteer = reminder.volunteer
    @reminder = reminder
    mail(to: @volunteer.contact.primary_email, subject: t('.subject'))
  end
end
