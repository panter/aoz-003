class Client < ApplicationRecord
  include LanguageAndScheduleReferences
  include SalutationCollection
  include YearCollection
  include BuildContactRelation

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

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  validates :state, inclusion: { in: STATES }

  scope :need_accompanying, lambda {
    includes(:assignment).where(assignments: { client_id: nil }).order(created_at: :asc)
  }

  GENDER_REQUESTS = [:no_matter, :same].freeze
  AGE_REQUESTS = [:age_no_matter, :age_young, :age_middle, :age_old].freeze
  PERMITS = [:N, :F, :'B-FL', :B, :C].freeze

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
