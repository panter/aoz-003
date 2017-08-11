module AvailabilityAttributes
  extend ActiveSupport::Concern

  included do
    def availability_attributes
      [
        :flexible, :morning, :afternoon, :evening, :workday, :weekend, :detailed_description
      ]
    end
  end
end
