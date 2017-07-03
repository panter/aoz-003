module RequestCollection
  extend ActiveSupport::Concern

  included do
    def self.gender_request_collection
      [:same, :no_matter]
    end

    def self.age_request_collection
      [:age_no_matter, :age_young, :age_middle, :age_old]
    end
  end
end
