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

  def base_assignment_entity
    return reminder_mailable if assignment?
    reminder_mailable.group_offer
  end

  def process_template
    {
      subject: replace_ruby_template(reminder_mailing.subject),
      body: replace_ruby_template(reminder_mailing.body)
    }
  end

  private

  def replace_ruby_template(template)
    template % template_variables
  rescue KeyError => _
    string_replace_key_error(template)
  end

  def string_replace_key_error(template)
    template.gsub(/\%\{([\w]*)\}/) do |key_match|
      key = key_match.remove('%{').remove('}').to_sym
      if template_variables[key].present?
        template_variables[key]
      else
        ''
      end
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
    @template_variables ||= ReminderMailing::TEMPLATE_VARNAMES.map do |varname|
      [varname, send(varname.to_s.underscore)]
    end.to_h
  end

  def feedback_link
    "[Feedback Geben](#{feedback_url})"
  end

  def feedback_url
    host_url + Rails.application.routes.url_helpers.polymorphic_path(
      reminder_mailable, action: :last_submitted_hours_and_feedbacks,
      rmv_id: id, rm_id: reminder_mailing.id
    )
  end

  def host_url
    if Rails.env.production?
      "https://#{ENV['DEVISE_EMAIL_DOMAIN'] || 'https://staging.aoz-freiwillige.ch'}"
    else
      'http://localhost:3000'
    end
  end
end
