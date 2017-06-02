class Client < ApplicationRecord
  include AssociatableFields
  include GenderCollection

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  validates :state, inclusion: { in: STATES }

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
