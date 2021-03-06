class Hour < ApplicationRecord
  include ImportRelation
  include ReviewsCommon

  belongs_to :volunteer, -> { with_deleted }, inverse_of: 'hours'

  belongs_to :hourable, polymorphic: true, optional: true

  belongs_to :reviewer, -> { with_deleted }, class_name: 'User', foreign_key: 'reviewer_id',
    inverse_of: 'reviewed_hours', optional: true

  belongs_to :billing_expense, -> { with_deleted }, optional: true, inverse_of: 'hours'
  belongs_to :certificate, optional: true

  validates :hours, presence: true, numericality: { greater_than: 0 }
  validates :meeting_date, presence: true
  validates :hourable, presence: true

  scope :billable, (-> { where(billing_expense: nil) })
  scope :billed, (-> { where.not(billing_expense: nil) })
  scope :semester, lambda { |date = nil|
    return all if date.blank?
    date = Time.zone.parse(date) unless date.is_a? Time
    return all if date.blank?
    semester_with_date(date)
  }

  scope :semester_with_date, lambda { |date|
    date_between_inclusion(:meeting_date, date.advance(days: 1),
      date.advance(months: BillingExpense::SEMESTER_LENGTH))
  }

  scope :since_last_submitted, lambda { |submitted_at|
    where('hours.created_at > ?', submitted_at) if submitted_at
  }

  scope :assignment, (-> { where(hourable_type: 'Assignment') })
  scope :group_offer, (-> { where(hourable_type: 'GroupOffer') })
  scope :from_assignments, lambda { |assignment_ids|
    assignment.where(hourable_id: assignment_ids)
  }
  scope :from_group_offers, lambda { |group_offer_ids|
    group_offer.where(hourable_id: group_offer_ids)
  }

  def assignment?
    hourable_type == 'Assignment'
  end

  def group_offer?
    hourable_type == 'GroupOffer'
  end

  def self.total_hours
    sum(:hours)
  end

  def hourable_id_and_type=(id_and_type)
    self.hourable_id, self.hourable_type = id_and_type.split(',', 2)
  end

  def hourable_id_and_type
    "#{hourable_id},#{hourable_type}"
  end
end
