class BillingExpense < ApplicationRecord
  include FullBankDetails

  before_validation :compute_amount
  belongs_to :volunteer
  belongs_to :user, -> { with_deleted }
  has_many :hours

  default_scope { order(created_at: :desc) }

  AMOUNT = [0, 50, 100, 150].freeze

  validates :amount, inclusion: { in: AMOUNT }

  def billing_hours
    relevant_hours = Hour.where(billing_expense: id)
    relevant_hours.sum(&:hours) + relevant_hours.sum(&:minutes) / 60
  end

  def billed_hours
    Hour.where(billing_expense: id)
  end

  def amount=(_value)
    super(compute_amount)
  end

  def compute_amount
    hour_count = id ? hours_sum : volunteer.billable_hours_sum
    if hour_count > 50
      150
    elsif hour_count > 25
      100
    elsif hour_count >= 1
      50
    else
      0
    end
  end

  def hours_sum
    hours.sum(&:hours) + hours.sum(&:minutes) / 60
  end
end
