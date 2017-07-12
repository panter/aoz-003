class Assignment < ApplicationRecord
  belongs_to :client
  belongs_to :volunteer
  belongs_to :user

  def self.state_collection
    [:suggested, :active]
  end
end
