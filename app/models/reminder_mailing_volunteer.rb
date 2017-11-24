class ReminderMailingVolunteer < ApplicationRecord
  attr_accessor :selected

  before_create :remove_or_process_email_content

  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, polymorphic: true, optional: true

  scope :group_assignment, (-> { where(reminder_mailable_type: 'GroupAssignment') })
  scope :assignment, (-> { where(reminder_mailable_type: 'Assignment') })

  scope :probation_period, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 0') })
  scope :half_year, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 1') })

  def process_template
    template_vars = template_variables
    {
      subject: reminder_mailing.subject % template_vars,
      body: reminder_mailing.body % template_vars
    }
  end

  private

  def remove_or_process_email_content
    destroy if selected && selected.to_i.zero?
  end

  def template_variables
    template_vars = {
      Anrede: I18n.t("salutation.#{volunteer.salutation}"),
      Name: "#{volunteer.contact.first_name} #{volunteer.contact.last_name}"
    }
    if reminder_mailable.class == Assignment
      template_vars[:Einsatz] = reminder_mailable.to_label
      template_vars[:EinsatzStart] = I18n.l(reminder_mailable.period_start)
    elsif reminder_mailable.class == GroupAssignment
      template_vars[:Einsatz] = reminder_mailable.group_offer.to_label
      template_vars[:EinsatzStart] = I18n.l(reminder_mailable.period_start)
    end
    template_vars
  end
end
