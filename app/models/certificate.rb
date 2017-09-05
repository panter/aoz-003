class Certificate < ApplicationRecord
  before_save :build_values

  belongs_to :volunteer
  belongs_to :user

  has_many :hours, through: :volunteer

  def build_values
    self.values = {
      hours: volunteer.hours.sum(:hours) + volunteer.hours.sum(:minutes) / 60,
      minutes: volunteer.hours.sum(:minutes) % 60,
      kinds: volunteer.assignment_kinds,
      duration: volunteer.assignments_duration
    }
  end
end
