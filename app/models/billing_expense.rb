class BillingExpense < ApplicationRecord
  include FullBankDetails

  belongs_to :volunteer
  belongs_to :user
  has_many :hours

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  validates :amount, inclusion: { in: AMOUNT }

  def billing_hours
    Hour.where(billing_expense: id).size
  end
end
