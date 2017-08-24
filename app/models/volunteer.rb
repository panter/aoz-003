class Volunteer < ApplicationRecord
  include LanguageReferences
  include SalutationCollection
  include BuildContactRelation
  include YearCollection
  include ZuerichScopes

  acts_as_paranoid
  before_save :default_state

  # States
  REGISTERED = 'registered'.freeze
  ACCEPTED = 'accepted'.freeze
  CONTACTED = 'contacted'.freeze
  ACTIVE = 'active'.freeze
  ACTIVE_FURTHER = 'active_further'.freeze
  REJECTED = 'rejected'.freeze
  INACTIVE = 'inactive'.freeze
  RESIGNED = 'resigned'.freeze

  STATES_FOR_REVIEWED = [
    CONTACTED, ACTIVE, ACCEPTED, ACTIVE_FURTHER, REJECTED, RESIGNED, INACTIVE
  ].freeze

  SEEKING_CLIENTS = [ACCEPTED, ACTIVE_FURTHER, INACTIVE].freeze

  STATES = STATES_FOR_REVIEWED.dup.unshift(REGISTERED).freeze

  belongs_to :user, optional: true
  belongs_to :registrar, optional: true,
    class_name: 'User', foreign_key: 'registrar_id'

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  has_many :assignments
  has_many :clients, through: :assignments
  has_many :hours, through: :assignments
  has_many :assignment_journals, through: :assignments

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :contact, presence: true
  validates :salutation, presence: true
  validates :state, inclusion: { in: STATES }
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  default_scope { order(created_at: :desc) }

  scope :seeking_clients, (-> { where(state: SEEKING_CLIENTS) })

  scope :with_assignments, (-> { joins(:assignments).distinct })
  scope :with_active_assignments, (-> { with_assignments.merge(Assignment.active) })
  scope :with_active_assignments_between, lambda { |start_date, end_date|
    with_assignments.merge(Assignment.active_between(start_date, end_date))
  }
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })

  def seeking_clients?
    SEEKING_CLIENTS.include?(state)
  end

  def registered?
    state == REGISTERED
  end

  def accepted?
    state == ACCEPTED
  end

  def rejected?
    state == REJECTED
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end

  SINGLE_ACCOMPANIMENTS = [:man, :woman, :family, :kid, :unaccompanied].freeze
  GROUP_ACCOMPANIMENTS = [:sport, :creative, :music, :culture, :training, :german_course,
                          :dancing, :health, :cooking, :excursions, :women, :teenagers,
                          :children, :other_offer].freeze
  REJECTIONS = [:us, :her, :other].freeze
  AVAILABILITY = [:flexible, :morning, :afternoon, :evening, :workday, :weekend].freeze

  def self.first_languages
    [
      [I18nData.languages(I18n.locale)['DE'], 'DE'],
      [I18nData.languages(I18n.locale)['EN'], 'EN'],
      [I18nData.languages(I18n.locale)['FR'], 'FR'],
      [I18nData.languages(I18n.locale)['ES'], 'ES'],
      [I18nData.languages(I18n.locale)['IT'], 'IT'],
      [I18nData.languages(I18n.locale)['AR'], 'AR']
    ]
  end

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  private

  def default_state
    self.state ||= REGISTERED
  end
end
