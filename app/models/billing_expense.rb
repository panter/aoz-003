class BillingExpense < ApplicationRecord
  include ImportRelation
  include FullBankDetails

  PERIOD = 6.months

  attr_accessor :import_mode

  before_validation :compute_amount, unless: :import_mode

  belongs_to :volunteer, -> { with_deleted }, inverse_of: :billing_expenses
  belongs_to :user, -> { with_deleted }, inverse_of: :billing_expenses
  has_many :hours, dependent: :nullify

  default_scope { order(created_at: :desc) }

  scope :period, lambda { |date|
    date = Time.zone.parse(date) unless date.is_a? Time

    joins(:hours)
      .merge(Hour.date_between(:meeting_date, date, date + PERIOD))
  }

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
    ['period']
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

  def self.generate_periods
    periods = []

    hours = Hour.billed
    oldest_date = hours.minimum(:meeting_date) || Time.zone.now
    newest_date = hours.maximum(:meeting_date) || Time.zone.now

    start_of_year = newest_date.beginning_of_year
    date = start_of_year
    date += PERIOD if newest_date >= start_of_year + PERIOD

    until date < oldest_date - PERIOD
      periods << {
        q: :period,
        value: date.strftime('%Y-%m-%d'),
        text: '%s - %s' % [
          I18n.l(date, format: '%B %Y'),
          I18n.l(date + PERIOD - 1.day, format: '%B %Y')
        ]
      }

      date -= PERIOD
    end

    periods
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
