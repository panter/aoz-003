class Assignment < ApplicationRecord
  belongs_to :client
  belongs_to :volunteer

  def self.state_collection
    [:suggested, :active]
  end
end
