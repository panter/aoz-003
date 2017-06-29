module YearCollection
  extend ActiveSupport::Concern

  included do
    def self.year_collection
    (90.year.ago.year.to_i...Date.today.year.to_i).to_a.map { |date| [date, Date.new(date)] }
    end
  end
end