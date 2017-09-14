class BillingExpense < ApplicationRecord
  include FullBankDetails

  belongs_to :volunteer
  belongs_to :user, -> { with_deleted }
  has_many :hours

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  validates :amount, inclusion: { in: AMOUNT }

  def billing_hours
    relevant_hours = Hour.where(billing_expense: id)
    relevant_hours.sum(&:hours) + relevant_hours.sum(&:minutes) / 60
  end

  def billed_hours
    Hour.where(billing_expense: id)
  end
end
