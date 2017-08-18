class Hour < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment

  validates :duration, presence: true
end
