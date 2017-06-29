module RequestCollection
  extend ActiveSupport::Concern

  included do
    def self.gender_request_collection
      [:same, :no_matter]
    end

    def self.age_request_collection
      [:age_no_matter, :'20-35', :'36-50', :'51']
    end
  end
end
