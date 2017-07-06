class VolunteerMailer < ApplicationMailer
  def welcome_email(volunteer, volunteer_email)
    @volunteer = volunteer
    @volunteer_email = volunteer_email
    mail(to: volunteer.contact.primary_email, subject: @volunteer_email.subject)
  end
end
