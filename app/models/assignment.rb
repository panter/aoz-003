class Assignment < ApplicationRecord
  belongs_to :client
  belongs_to :volunteer
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  def self.state_collection
    [:suggested, :active]
  end
end
