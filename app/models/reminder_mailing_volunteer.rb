class ReminderMailingVolunteer < ApplicationRecord
  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, polymorphic: true, optional: true

  scope :un_selected, (-> { where(selected: false) })
  scope :toggled, (-> { where(selected: true) })
  scope :group_assignment, (-> { where(reminder_mailable_type: 'GroupAssignment') })
  scope :assignment, (-> { where(reminder_mailable_type: 'Assignment') })

  scope :probation_period, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 0') })
  scope :half_year, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 1') })

  def process_template
    template_vars = template_variables
    begin
      { subject: reminder_mailing.subject % template_vars,
        body: reminder_mailing.body % template_vars }
    rescue KeyError => _
      { subject: string_replace_key_error(reminder_mailing.subject, template_vars),
        body: string_replace_key_error(reminder_mailing.body, template_vars) }
    end
  end

  def string_replace_key_error(string, variables)
    string.gsub(/\%\{([\w]*)\}/) do |key_match|
      key = key_match.remove('%{').remove('}').to_sym
      if variables[key].present?
        variables[key]
      else
        ''
      end
    end
  end

  def assignment?
    reminder_mailable.class == Assignment
  end

  def group_assignment?
    reminder_mailable.class == GroupAssignment
  end

  def mailable_to_label
    if assignment?
      reminder_mailable.to_label
    elsif group_assignment?
      reminder_mailable.group_offer.to_label
    end
  end

  private

  def anrede
    I18n.t("salutation.#{volunteer.salutation}")
  end

  def name
    volunteer.contact.natural_name
  end

  def einsatz_start
    I18n.l(reminder_mailable.period_start)
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

  # TODO: this path will need to come with the TrialFeedback implementation
  # For now this Route doesn't exist yet, so only this comment for now
  # url_for(TrialFeedback.new(feedbackable: reminder_mailable, volunteer: volunteer))
  def feedback_link
    ''
  end

  def template_variables
    ReminderMailing::TEMPLATE_VARNAMES.map do |varname|
      [varname, send(varname.to_s.underscore)]
    end.to_h
  end
end
