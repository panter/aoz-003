class Hour < ApplicationRecord
  include ImportRelation
  include ReviewsCommon

  belongs_to :volunteer, -> { with_deleted }, inverse_of: 'hours'

  belongs_to :hourable, polymorphic: true, optional: true

  belongs_to :reviewer, -> { with_deleted }, class_name: 'User', foreign_key: 'reviewer_id',
    inverse_of: 'reviewed_hours', optional: true

  belongs_to :billing_expense, -> { with_deleted }, optional: true, inverse_of: 'hours'
  belongs_to :certificate, optional: true

  belongs_to :semester_process_volunteer, optional: true

  validates :hours, presence: true, numericality: { greater_than: 0 }
  validates :meeting_date, presence: true
  validates :hourable, presence: true
  validate :meeting_date_impossibly_old, on: :create

  scope :billable, (-> { where('hours.billing_expense_id IS NULL') })
  scope :billed, (-> { where.not(billing_expense: nil) })
  scope :order_by_meeting_date, (-> { order(meeting_date: :asc) })

  scope :meeting_date_between, lambda { |date_range|
    where(
      'hours.meeting_date >= :start_date AND hours.meeting_date <= :end_date',
      start_date: date_range.first, end_date: date_range.last
    )
  }

  scope :volunteer_not_waive, lambda {
    where(volunteers: { waive: false })
  }

  scope :volunteer_not_billed_in_semester, lambda { |date|
    where('volunteers.last_billing_expense_on IS NULL').or(
      where.not('volunteers.last_billing_expense_on::date = ?', date)
    )
  }

  scope :order_volunteer_iban_name, lambda {
    sort_sql = <<-SQL.squish
      (CASE
        WHEN COALESCE(volunteers.iban, '') = ''
        THEN 2
        ELSE 1
      END),
      contacts.full_name ASC,
      hours.meeting_date ASC
    SQL
    order(Arel.sql(sort_sql))
  }

  scope :semester, lambda { |date = nil|
    return all if date.blank?

    date = Time.zone.parse(date) unless date.is_a? Time
    return all if date.blank?

    semester_with_date(date)
  }

  scope :semester_with_date, lambda { |date|
    date_between_inclusion(
      :meeting_date,
      date,
      date.advance(months: BillingExpense::SEMESTER_LENGTH)
    )
  }

  scope :within_semester, lambda { |semester|
    where(meeting_date: semester.begin...semester.end.advance(days: 1)).order_by_meeting_date
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

  attr_reader :spv_mission_id

  def spv_mission_id=(id)
    spv_mission = SemesterProcessVolunteerMission.find(id)
    self.hourable = spv_mission.mission.group_assignment? ? spv_mission.mission.group_offer : spv_mission.mission
  end

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

  private

  def meeting_date_impossibly_old
    errors.add(:meeting_date, :too_long_ago) if meeting_date < 1.year.ago.to_date
  end
end
