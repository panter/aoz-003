class Client < ApplicationRecord
  include LanguageReferences
  include SalutationCollection
  include YearCollection
  include BuildContactRelation
  include ZuerichScopes
  include ImportRelation

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user, -> { with_deleted }

  has_one :assignment
  has_one :volunteer, through: :assignments

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  validates :state, inclusion: { in: STATES }

  scope :default_order, (-> { order(created_at: :desc) })

  scope :need_accompanying, lambda {
    includes(:assignment).where(assignments: { client_id: nil }).order(created_at: :asc)
  }

  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :created_before, ->(max_time) { where('clients.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('clients.created_at > ?', min_time) }

  scope :with_assignment, (-> { joins(:assignment) })
  scope :with_active_assignment, (-> { with_assignment.merge(Assignment.active) })

  scope :with_active_assignment_between, lambda { |start_date, end_date|
    with_assignment.merge(Assignment.active_between(start_date, end_date))
  }

  scope :with_inactive_assignment, (-> { with_assignment.merge(Assignment.ended) })

  scope :without_assignment, lambda {
    left_outer_joins(:assignment).where(assignments: { id: nil })
  }

  GENDER_REQUESTS = [:no_matter, :same].freeze
  AGE_REQUESTS = [:age_no_matter, :age_young, :age_middle, :age_old].freeze
  PERMITS = [:N, :F, :'B-FL', :B, :C].freeze

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  def self.first_languages
    [
      [I18nData.languages(I18n.locale)['TI'], 'TI'],
      ['Dari', 'DR'],
      [I18nData.languages(I18n.locale)['AR'], 'AR'],
      ['Farsi', 'FS'],
      [I18nData.languages(I18n.locale)['DE'], 'DE'],
      [I18nData.languages(I18n.locale)['EN'], 'EN']
    ]
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
