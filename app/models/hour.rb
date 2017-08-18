class Hour < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment

  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :meeting_date, presence: true
end
