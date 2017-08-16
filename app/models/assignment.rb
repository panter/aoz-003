class Assignment < ApplicationRecord
  belongs_to :client
  accepts_nested_attributes_for :client
  belongs_to :volunteer
  accepts_nested_attributes_for :volunteer
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :hours

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  STATES = [:suggested, :active].freeze
end
