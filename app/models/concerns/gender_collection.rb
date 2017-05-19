module GenderCollection
  extend ActiveSupport::Concern

  included do
    def self.gender_collection
      [:female, :male]
    end
  end
end
