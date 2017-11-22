class VolunteerMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  def welcome_email(volunteer, signup_email)
    @volunteer = volunteer
    @signup_email = signup_email
    mail(to: volunteer.contact.primary_email, subject: @signup_email.subject)
  end
end
