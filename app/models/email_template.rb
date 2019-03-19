class EmailTemplate < ApplicationRecord
  before_save :ensure_exactly_one_active_per_kind

  enum kind: { signup: 0, trial: 1, termination: 2, half_year_process_email: 4, half_year_process_overdue: 5 }
  validates :kind, presence: true

  scope :order_by_active, -> { order(active: :desc) }

  def self.active
    where(active: true)
  end

  def self.kind_collection
    kinds.keys.map(&:to_sym)
  end

  def self.active_as_hash
    EmailTemplate.active.map do |templ|
      [templ.kind, templ.template_hash]
    end.to_h
  end

  def template_hash
    {
      body: body,
      subject: subject
    }
  end

  def self.template_varnames
    {
      signup: [],
      assignment: [:Anrede, :Name, :EinsatzTitel, :FeedbackLink],
      trial: ReminderMailing.template_varnames(:trial_period).values,
      termination: ReminderMailing.template_varnames(:termination).values,
      half_year_process_email: ReminderMailing.template_varnames(:half_year_process_email).values,
      half_year_process_overdue: ReminderMailing.template_varnames(:half_year_process_overdue).values
    }
  end

  def ensure_exactly_one_active_per_kind
    return unless active && changed.include?('active')
    EmailTemplate.where(kind: kind).update(active: false)
  end
end
