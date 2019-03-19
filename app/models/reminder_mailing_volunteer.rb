class ReminderMailingVolunteer < ApplicationRecord
  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, -> { with_deleted }, polymorphic: true, optional: true

  belongs_to :process_submitted_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'mailing_volunteer_processes_submitted', optional: true

  scope :group_assignment, (-> { where(reminder_mailable_type: 'GroupAssignment') })
  scope :assignment, (-> { where(reminder_mailable_type: 'Assignment') })

  scope :picked, (-> { where(picked: true) })

  scope :kind, ->(kind) { joins(:reminder_mailing).where('reminder_mailings.kind = ?', kind) }
  scope :trial_period, (-> { kind(ReminderMailing.kinds[:trial_period]) })
  scope :termination, (-> { kind(ReminderMailing.kinds[:termination]) })
  scope :termination_for, ->(mailable) { termination.where(reminder_mailable: mailable) }

  delegate :full_name, to: :volunteer

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

  def base_entity
    return reminder_mailable if assignment?
    reminder_mailable.group_offer
  end

  def process_template
    {
      subject: replace_ruby_template(reminder_mailing.subject),
      body: replace_ruby_template(reminder_mailing.body)
    }
  end

  def current_submission
    date = reminder_mailable.submitted_at
    date if date && date > reminder_mailing.created_at
  end

  def feedback_url(options = {})
    if reminder_mailing.trial_period?
      path = [volunteer, reminder_mailable.polymorph_url_object, TrialFeedback]
      action = :new
    elsif reminder_mailing.termination?
      path = reminder_mailable
      action = :terminate
    else
      return
    end

    Rails.application.routes.url_helpers.polymorphic_url(
      path,
      ActionMailer::Base.default_url_options.merge(options.merge(action: action))
    )
  end

  private

  def replace_ruby_template(template)
    template % template_variables
  end

  def template_variables
    template_variables = reminder_mailing.template_varnames.map do |method_name, var_name|
      [var_name, send(method_name)]
    end.to_h

    template_variables.default = ''
    template_variables
  end

  ## template variable converters
  #
  # there needs to be a method with the name matching each value
  # from ReminderMailing::TEMPLATE_VARNAMES
  # Otherwise there will be a method missing error if that template variable is used
  def anrede
    I18n.t("salutation.#{volunteer.salutation}")
  end

  def name
    volunteer.contact.natural_name
  end

  def einsatz_start
    I18n.l(reminder_mailable.period_start) if reminder_mailable.period_start
  end

  def einsatz
    if assignment?
      "Tandem mit #{reminder_mailable.client.contact.natural_name}"
    elsif group_assignment?
      einsatz_text = "Gruppenangebot #{reminder_mailable.group_offer.title}"
      if reminder_mailable.group_offer.department.present?
        einsatz_text += " (#{reminder_mailable.group_offer.department})"
      end
      einsatz_text
    end
  end

  def email_absender
    "[#{reminder_mailing_creator_name}](mailto:"\
      "#{reminder_mailing.creator.email})"
  end

  def feedback_link_trial
    "[Probezeit-Feedback erstellen](#{feedback_url})"
  end

  def feedback_link_termination
    "[Abschlussevaluations-Feedback erstellen](#{feedback_url})"
  end

  def feedback_link_semester
    "[Halbjahres-Feedback erstellen](#{feedback_url})"
  end

  def online_plattform_url
    "[Online-Plattform Url](#{Rails.application.routes.url_helpers.root_path})"
  end

  # template variable assisting methods
  def reminder_mailing_creator_name
    reminder_mailing.creator.profile&.contact&.natural_name ||
      reminder_mailing.creator.email
  end
end
