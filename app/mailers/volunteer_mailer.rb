class VolunteerMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  def welcome_email(volunteer, signup_email)
    @volunteer = volunteer
    @signup_email = signup_email
    subject = signup_email.subject
    subject.gsub! '%<anrede>', t("salutation.#{volunteer.salutation}")
    subject.gsub! '%<name>', "#{volunteer.contact.first_name} #{volunteer.contact.last_name}"
    body = signup_email.body
    body.gsub! '%<anrede>', t("salutation.#{volunteer.salutation}")
    body.gsub! '%<name>', "#{volunteer.contact.first_name} #{volunteer.contact.last_name}"
    mail(to: @volunteer.contact.primary_email, subject: @signup_email.subject)
  end
end
