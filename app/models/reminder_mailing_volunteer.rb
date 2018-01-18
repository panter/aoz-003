class ReminderMailingVolunteer < ApplicationRecord
  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, polymorphic: true, optional: true

  belongs_to :process_submitted_by, class_name: 'User', optional: true

  scope :group_assignment, (-> { where(reminder_mailable_type: 'GroupAssignment') })
  scope :assignment, (-> { where(reminder_mailable_type: 'Assignment') })

  scope :trial_period, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 0') })
  scope :half_year, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 1') })
  scope :termination, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 2') })

  scope :picked, (-> { where(picked: true) })

  # TODO: waits for enum to exist from other not yet merged feature story
  scope :termination, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = ?', 2) })
  scope :termination_for, ->(mailable) { termination.where(reminder_mailable: mailable) }

  def mark_process_submitted(user, terminate_parent_mailing: false)
    update(process_submitted_by: user, process_submitted_at: Time.zone.now)
    reminder_mailing.update(obsolete: true) if terminate_parent_mailing
  end

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
      template_variables[key].presence || ''
    end
  end

  def anrede
    I18n.t("salutation.#{volunteer.salutation}", locale: :de)
  end

  def name
    volunteer.contact.natural_name
  end

  def einsatz_start
    I18n.l(reminder_mailable.period_start, locale: :de) if reminder_mailable.period_start
  end

  def einsatz
    if assignment?
      "Tandem mit #{reminder_mailable.client.contact.natural_name}"
    elsif group_assignment?
      einsatz_text = "Gruppenangebot #{reminder_mailable.group_offer.title}"
      if reminder_mailable.group_offer.department.present?
        einsatz_text += " (#{reminder_mailable.group_offer.department.to_s})"
      end
      einsatz_text
    end
  end

  def template_variables
    @template_variables ||= ReminderMailing::TEMPLATE_VARNAMES.map do |varname|
      [varname, send(varname.to_s.underscore)]
    end.to_h
  end

  def email_absender
    "[#{reminder_mailing.creator.profile.contact.natural_name}](mailto:#{reminder_mailing.creator.email})"
  end

  def feedback_link
    "[Feedback Geben](#{feedback_url})"
  end

  def feedback_url
    if reminder_mailing.half_year?
      make_polymorphic_path(reminder_mailable, :last_submitted_hours_and_feedbacks)
    elsif reminder_mailing.trial_period?
      make_polymorphic_path([volunteer, reminder_mailable.polymorph_url_object, TrialFeedback],
        :new)
    end
  end

  def make_polymorphic_path(path_array, action)
    host_url + Rails.application.routes.url_helpers.polymorphic_path(
      path_array, action: action, rmv_id: id, rm_id: reminder_mailing.id
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
