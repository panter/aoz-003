class EmailTemplate < ApplicationRecord
  before_save :ensure_exactly_one_active_per_kind

  enum kind: { signup: 0, trial: 1, assignment: 2 }
  validates :kind, presence: true

  default_scope { order(active: :desc) }

  def self.active
    where(active: true)
  end

  def self.kind_collection
    kinds.keys.map(&:to_sym)
  end

  def ensure_exactly_one_active_per_kind
    return unless active && changed.include?('active')
    EmailTemplate.where(kind: kind).update(active: false)
  end
end
