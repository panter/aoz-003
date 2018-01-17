class Client < ApplicationRecord
  include LanguageReferences
  include YearCollection
  include BuildContactRelation
  include ZuerichScopes
  include ImportRelation

  enum acceptance: { accepted: 0, rejected: 1, resigned: 2 }
  enum cost_unit: { city: 0, municipality: 1, canton: 2 }

  GENDER_REQUESTS = [:no_matter, :man, :woman].freeze
  AGE_REQUESTS = [:age_no_matter, :age_young, :age_middle, :age_old].freeze
  PERMITS = [:N, :F, :'B-FL', :B, :C].freeze
  SALUTATIONS = [:mrs, :mr, :family].freeze

  belongs_to :user, -> { with_deleted }
  belongs_to :involved_authority, class_name: 'User', optional: true

  has_one :assignment, dependent: :destroy
  has_one :volunteer, through: :assignments

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  validates :salutation, presence: true

  scope :need_accompanying, lambda {
    inactive.order(created_at: :asc)
  }

  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :created_before, ->(max_time) { where('clients.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('clients.created_at > ?', min_time) }

  scope :with_assignment, (-> { joins(:assignment) })
  scope :with_active_assignment, (-> { with_assignment.merge(Assignment.active) })

  scope :with_active_assignment_between, lambda { |start_date, end_date|
    with_assignment.merge(Assignment.active_between(start_date, end_date))
  }

  scope :with_inactive_assignment, lambda {
    left_outer_joins(:assignment)
      .where('assignments.period_end < ?', Time.zone.today)
  }

  scope :without_assignment, lambda {
    left_outer_joins(:assignment).where('assignments.id is NULL')
  }

  scope :active, lambda {
    accepted.with_active_assignment
  }

  scope :inactive, lambda {
    accepted.without_assignment.or(with_inactive_assignment)
  }

  def self.acceptance_collection
    acceptances.keys.map(&:to_sym)
  end

  def self.cost_unit_collection
    cost_units.keys.map(&:to_sym)
  end

  def to_s
    contact.full_name
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

  def german_missing?
    language_skills.german.blank?
  end
end
