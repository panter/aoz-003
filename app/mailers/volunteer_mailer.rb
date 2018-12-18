class VolunteerMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  add_template_helper(MarkdownHelper)

  def welcome_email(volunteer, signup_email)
    @volunteer = volunteer
    @signup_email = signup_email

    template_variables = {
      Anrede: I18n.t("salutation.#{volunteer.salutation}"),
      Name: "#{volunteer.contact.first_name} #{volunteer.contact.last_name}"
    }
    template_variables.default = ''

    @subject = signup_email.subject % template_variables
    @body = signup_email.body % template_variables
    mail(to: @volunteer.contact.primary_email, subject: @subject)
  end

  def termination(reminder_mailing_volunteer)
    @volunteer = reminder_mailing_volunteer.volunteer
    @subject, @body = reminder_mailing_volunteer.process_template.values_at(:subject, :body)
    reminder_mailing_volunteer.update(email_sent: true)
    mail(to: @volunteer.contact.primary_email, subject: @subject)
  end

  def trial_period(reminder_mailing_volunteer)
    @volunteer = reminder_mailing_volunteer.volunteer
    @subject, @body = reminder_mailing_volunteer.process_template.values_at(:subject, :body)
    reminder_mailing_volunteer.update(email_sent: true)
    mail(to: @volunteer.contact.primary_email, subject: @subject)
  end

  def half_year_process_email(semester_process_mail)
    @volunteer = semester_process_mail.volunteer
    @subject, @body = semester_process_mail.process_template.values_at(:subject, :body)
    mail(to: @volunteer.contact.primary_email, subject: @subject)
  end
end
