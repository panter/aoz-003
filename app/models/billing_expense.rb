class BillingExpense < ApplicationRecord
  include ImportRelation
  include FullBankDetails

  attr_accessor :import_mode

  before_validation :compute_amount, unless: :import_mode

  belongs_to :volunteer, -> { with_deleted }, inverse_of: 'billing_expenses'
  belongs_to :user, -> { with_deleted }, inverse_of: 'billing_expenses'
  has_many :hours, dependent: :nullify

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  validates :amount, inclusion: { in: AMOUNT }, unless: :import_mode

  private

  def compute_amount
    hour_count = id ? hours.total_hours : volunteer.hours.billable.total_hours
    if hour_count > 50
      self.amount = 150
    elsif hour_count > 25
      self.amount = 100
    elsif hour_count >= 1
      self.amount = 50
    else
      self.amount = 0
    end
  end
end
