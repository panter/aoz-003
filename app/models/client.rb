class Client < ApplicationRecord
  include LanguageAndScheduleReferences
  include GenderCollection
  include YearCollection

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  has_one :assignment
  has_one :volunteer, through: :assignments

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  validates :state, inclusion: { in: STATES }

  def self.gender_request_collection
    [:same, :no_matter]
  end

  def self.age_request_collection
    [:age_no_matter, :age_young, :age_middle, :age_old]
  end

  def self.without_assignments
    # TODO: think about optimizing without subquery
    Client.where.not(id: Assignment.select(:client_id))
  end

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
