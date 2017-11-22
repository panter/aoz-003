class ReminderMailingVolunteer < ApplicationRecord
  attr_accessor :selected

  before_create :remove_or_process_email_content

  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, polymorphic: true, optional: true

  private

  def remove_or_process_email_content
    return destroy if selected && selected.to_i.zero?
    self.body = reminder_mailing.body % template_variables
    self.subject = reminder_mailing.subject % template_variables
  end

  def template_variables
    template_vars = {
      Anrede: I18n.t("salutation.#{volunteer.salutation}"),
      Name: "#{volunteer.contact.first_name} #{volunteer.contact.last_name}"
    }
    if reminder_mailable.class == Assignment
      template_vars[:Begleitung] = reminder_mailable.title
    elsif reminder_mailable.class == GroupAssignment
      template_vars[:Gruppenangebot] = reminder_mailable.group_offer.title
    end
    template_vars
  end
end
