class ReminderMailingVolunteer < ApplicationRecord

  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, polymorphic: true, optional: true

  scope :group_assignment, (-> { where(reminder_mailable_type: 'GroupAssignment') })
  scope :assignment, (-> { where(reminder_mailable_type: 'Assignment') })

  scope :probation_period, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 0') })
  scope :half_year, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 1') })

  scope :picked, (-> { where(picked: true) })

  def assignment?
    reminder_mailable_type == 'Assignment'
  end

  def group_assignment?
    reminder_mailable_type == 'GroupAssignment'
  end

  def mailable_to_label
    base_assignment_entity.to_label
  end

  private

  def base_assignment_entity
    if assignment?
      reminder_mailable
    elsif group_assignment?
      reminder_mailable.group_offer
    end
  end

  def anrede
    I18n.t("salutation.#{volunteer.salutation}", locale: :de)
  end

  def name
    volunteer.contact.natural_name
  end

  def einsatz_start
    I18n.l(reminder_mailable.period_start, locale: :de)
  end

  def einsatz
    if assignment?
      "Tandem mit #{reminder_mailable.client.contact.natural_name}"
    elsif group_assignment?
      einsatz_text = "Gruppenangebot #{reminder_mailable.group_offer.title}"
      if reminder_mailable.group_offer.department.present?
        einsatz_text += " (#{reminder_mailable.group_offer.department.to_label})"
      end
      einsatz_text
    end
  end

  def template_variables
    ReminderMailing::TEMPLATE_VARNAMES.map do |varname|
      [varname, send(varname.to_s.underscore)]
    end.to_h
  end

  def feedback_link
    "[Feedback Geben](#{feedback_url})"
  end

  def feedback_url
    url_options = ActionMailer::Base.default_url_options
    url_options[:protocol] || 'http://' + url_options[:host] +
      Rails.application.routes.url_helpers.polymorphic_path(
        [volunteer, base_assignment_entity, TrialFeedback],
        action: :new, rmv_id: id, rm_id: reminder_mailing.id
      )
  end
end
