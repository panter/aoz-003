module StateCollection
  extend ActiveSupport::Concern

  included do
    def self.state_collection
      [:registered, :reserved, :active, :finished, :rejected]
    end
  end
end
