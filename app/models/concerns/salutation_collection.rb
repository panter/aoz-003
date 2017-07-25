module SalutationCollection
  extend ActiveSupport::Concern

  included do
    def self.salutation_collection
      [:mrs, :mr]
    end
  end
end
