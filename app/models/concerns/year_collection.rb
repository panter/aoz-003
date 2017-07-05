module YearCollection
  extend ActiveSupport::Concern

  included do
    def self.year_collection
      (90.years.ago.year.to_i...Time.zone.today.year.to_i).to_a.map { |date| [date, Date.new(date)] }
    end
  end
end
