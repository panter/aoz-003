class Client < ApplicationRecord
  include AssociatableFields
  include FullName
  include GenderCollection

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  validates :first_name, :last_name, presence: true
  validates :state, inclusion: { in: STATES }

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
