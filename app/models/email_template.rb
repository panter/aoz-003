class EmailTemplate < ApplicationRecord
  before_save :ensure_exactly_one_active_per_kind

  enum kind: { signup: 0, trial: 1, half_year: 2, termination: 3 }
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
      trial: ReminderMailing::TEMPLATE_VARNAMES,
      half_year: ReminderMailing::TEMPLATE_VARNAMES,
      signup: EmailTemplate.template_variables,
      assignment: EmailTemplate.template_variables,
      termination: EmailTemplate.template_variables
    }
  end

  def self.template_variables
    [:Anrede, :Name, :EinsatzTitel, :FeedbackLink]
  end

  def ensure_exactly_one_active_per_kind
    return unless active && changed.include?('active')
    EmailTemplate.where(kind: kind).update(active: false)
  end
end
