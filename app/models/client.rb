class Client < ApplicationRecord
  include LanguageAndScheduleReferences
  include GenderCollection
  include RequestCollection
  include YearCollection

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  validates :state, inclusion: { in: STATES }

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
