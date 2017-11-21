class ReminderMailing < ApplicationRecord
  belongs_to :creator, -> { with_deleted }, class_name: 'User'
  has_many :reminder_mailing_volunteers
  has_many :volunteers, through: :reminder_mailing_volunteers
  enum kind: { probation_period: 1, half_year: 0 }

  def self.kind_collection
    kind.keys.map(&:to_sym)
  end
end
