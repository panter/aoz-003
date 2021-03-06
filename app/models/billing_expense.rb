class BillingExpense < ApplicationRecord
  include ImportRelation
  include FullBankDetails
  include BillingExpenseSemesterUtils

  SEMESTER_LENGTH = 6

  attr_accessor :import_mode

  before_validation :compute_amount, unless: :import_mode

  belongs_to :volunteer, -> { with_deleted }, inverse_of: :billing_expenses
  belongs_to :user, -> { with_deleted }, inverse_of: :billing_expenses
  has_many :hours, dependent: :nullify

  default_scope { order(created_at: :desc) }

  scope :semester, ->(date) { joins(:hours).merge(Hour.semester(date)) }

  FINAL_AMOUNT_SQL = "CASE WHEN overwritten_amount IS NULL THEN amount ELSE overwritten_amount END".freeze
  scope :sort_by_final_amount_asc, lambda {
    order("#{FINAL_AMOUNT_SQL} asc")
  }
  scope :sort_by_final_amount_desc, lambda {
    order("#{FINAL_AMOUNT_SQL} desc")
  }

  AMOUNT = [50, 100, 150].freeze

  validates :volunteer, :user, :iban, presence: true
  validates :amount, inclusion: { in: AMOUNT }, unless: :import_mode

  def self.ransackable_scopes(auth_object = nil)
    ['semester']
  end

  def ransortable_attributes(auth_object = nil)
    super(auth_object) + [
      :sort_by_final_amount_asc,
      :sort_by_final_amount_desc,
    ]
  end

  def self.amount_for(hours)
    if hours > 50
      150
    elsif hours > 25
      100
    elsif hours > 0
      50
    else
      0
    end
  end

  def self.create_for!(volunteers, creator, date = nil)
    billing_semester = billable_semester_date(date)
    transaction do
      volunteers.find_each do |volunteer|
        hours = volunteer.hours.billable.semester(billing_semester)
        hours.find_each { |hour| hour.update!(reviewer: creator) }

        create!(
          volunteer: volunteer,
          user: creator,
          hours: hours,
          bank: volunteer.bank,
          iban: volunteer.iban
        )
        volunteer.update!(last_billing_expense_on: billing_expense_semester(billing_semester))
      end
    end
  end

  def self.generate_semester_filters(scope)
    scoped_hours = Hour.public_send(scope)
    first_semester = semester_from_hours(scoped_hours, date_position: :minimum)
    last_semester = semester_from_hours(scoped_hours)

    semesters = [semester_filter_hash(last_semester)]
    semester_back_count(first_semester.to_time, last_semester.to_time).times do
      last_semester = last_semester.advance(months: -SEMESTER_LENGTH)
      next if scoped_hours.semester(last_semester).blank?
      semesters << semester_filter_hash(last_semester)
    end
    semesters
  end

  def self.semester_filter_hash(date)
    { q: :semester, value: date.strftime('%Y-%m-%d'),
      text: I18n.t('semester.one_semester', number: semester_of_year(date),
              year: semester_display_year(date)) }
  end

  def final_amount
    overwritten_amount.presence || amount
  end

  def edited_amount?
    overwritten_amount? && overwritten_amount != amount
  end

  private

  def compute_amount
    return if hours.blank?

    # FIXME: we can't use total_hours here because of some weirdness
    # with ActiveRecord::AssociationRelation
    self.amount = self.class.amount_for(hours.sum(&:hours))
  end
end
