class BillingExpense < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  validates :amount, inclusion: { in: AMOUNT }

  def self.amount_collection
    AMOUNT.map(&:to_s)
  end
end
