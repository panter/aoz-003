class EmailTemplate < ApplicationRecord
  before_save :ensure_exactly_one_active_per_kind

  enum kind: { signup: 0, trial: 1, assignment: 2 }
  validates :kind, presence: true

  default_scope { order(created_at: :desc) }
  scope :active_mail, -> { where(active: true) }

  def self.kind_collection
    kinds.keys.map(&:to_sym)
  end

  def ensure_exactly_one_active_per_kind
    return unless active && changed.include?('active')
    EmailTemplate.where(kind: kind, active: true).update(active: false)
  end
end
