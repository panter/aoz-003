class PerformanceReport < ApplicationRecord
  before_validation :make_report
  belongs_to :user

  def make_report
    binding.pry
    {
      volunteer: {
        total: Volunteer.count
      }
    }
  end
end
