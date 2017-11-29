class VolunteerMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  def welcome_email(volunteer, signup_email)
    @volunteer = volunteer
    @signup_email = signup_email
    template_variables = {
      Anrede: I18n.t("salutation.#{volunteer.salutation}"),
      Name: "#{volunteer.contact.first_name} #{volunteer.contact.last_name}"
    }
    @subject = signup_email.subject % template_variables
    @body = signup_email.body % template_variables
    mail(to: @volunteer.contact.primary_email, subject: @subject)
  end
end
