class ReminderMailingVolunteer < ApplicationRecord
  attr_reader :selected

  before_create :remove_if_not_selected

  belongs_to :reminder_mailing
  belongs_to :volunteer
  belongs_to :reminder_mailable, polymorphic: true, optional: true

  scope :group_assignment, (-> { where(reminder_mailable_type: 'GroupAssignment') })
  scope :assignment, (-> { where(reminder_mailable_type: 'Assignment') })

  scope :probation_period, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 0') })
  scope :half_year, (-> { joins(:reminder_mailing).where('reminder_mailings.kind = 1') })

  def selected=(value)
    @selected = value == '1'
  end

  def process_template
    template_vars = template_variables
    {
      subject: reminder_mailing.subject % template_vars,
      body: reminder_mailing.body % template_vars
    }
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

  TEMPLATE_VARNAMES = [:Anrede, :Einsatz, :Name, :EinsatzStart, :FeedbackLink].freeze

  private

  def remove_if_not_selected
    delete unless @selected
  end

  def template_variables
    template_hash = ReminderMailing::TEMPLATE_VARNAMES.map { |varname| [varname, ''] }.to_h
    template_hash[:Anrede] = I18n.t("salutation.#{volunteer.salutation}")
    template_hash[:Einsatz] = mailable_to_label
    template_hash[:Name] = volunteer.contact.natural_name
    template_hash[:EinsatzStart] = I18n.l(reminder_mailable.period_start)
    # TODO: this path will need to come with the TrialFeedback implementation
    # For now this Route doesn't exist yet, so only this comment for now
    # url_for(TrialFeedback.new(feedbackable: reminder_mailable, volunteer: volunteer))
    template_hash[:FeedbackLink] = ''
    template_hash
  end
end
