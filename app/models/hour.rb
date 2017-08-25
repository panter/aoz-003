class Hour < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment

  validates :hours, presence: true, numericality: { greater_than: 0 }
  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :meeting_date, presence: true
end
