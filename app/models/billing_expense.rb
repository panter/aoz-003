class BillingExpense < ApplicationRecord
  include FullBankDetails

  belongs_to :volunteer
  belongs_to :user
  has_many :hours

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  PAID = 'paid'.freeze
  UNPAID = 'unpaid'.freeze
  STATES = [PAID, UNPAID].freeze

  validates :amount, inclusion: { in: AMOUNT }
  validates :state, inclusion: { in: STATES }

  def self.amount_collection
    AMOUNT.map(&:to_s)
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
