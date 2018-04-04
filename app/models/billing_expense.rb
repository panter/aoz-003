class BillingExpense < ApplicationRecord
  include ImportRelation
  include FullBankDetails

  attr_accessor :import_mode

  before_validation :compute_amount, unless: :import_mode

  belongs_to :volunteer, -> { with_deleted }, inverse_of: :billing_expenses
  belongs_to :user, -> { with_deleted }, inverse_of: :billing_expenses
  has_many :hours, dependent: :nullify

  default_scope { order(created_at: :desc) }

  AMOUNT = [50, 100, 150].freeze

  validates :volunteer, :user, :iban, presence: true
  validates :amount, inclusion: { in: AMOUNT }, unless: :import_mode

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

  def self.create_for!(volunteers, creator)
    transaction do
      volunteers.find_each do |volunteer|
        hours = volunteer.hours.billable
        hours.find_each do |hour|
          hour.update!(reviewer: creator)
        end

        create!(
          volunteer: volunteer,
          user: creator,
          hours: hours,
          bank: volunteer.bank,
          iban: volunteer.iban
        )
      end
    end
  end

  private

  def compute_amount
    return if hours.blank?

    # FIXME: we can't use total_hours here because of some weirdness
    # with ActiveRecord::AssociationRelation
    self.amount = self.class.amount_for(hours.sum(&:hours))
  end
end
