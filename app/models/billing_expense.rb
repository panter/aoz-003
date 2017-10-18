class BillingExpense < ApplicationRecord
  include FullBankDetails

  before_validation :compute_amount

  belongs_to :volunteer
  belongs_to :user, -> { with_deleted }
  has_many :hours

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  validates :amount, inclusion: { in: AMOUNT }

  def compute_amount
    hour_count = id ? hours.total_hours : volunteer.hours.billable.total_hours
    return self.amount = 150 if hour_count > 50
    return self.amount = 100 if hour_count > 25
    return self.amount = 50 if hour_count >= 1
    self.amount = 0
  end
end
