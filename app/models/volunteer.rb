class Volunteer < ApplicationRecord
  include LanguageAndScheduleReferences
  include SalutationCollection
  include BuildContactRelation
  include YearCollection

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

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  has_many :assignments
  has_many :clients, through: :assignments

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :contact, presence: true
  validates :state, inclusion: { in: STATES }
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  scope :seeking_clients, (-> { where(state: SEEKING_CLIENTS) })

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

  def self.human_boolean(boolean)
    boolean ? I18n.t('simple_form.yes') : I18n.t('simple_form.no')
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end

  DURATIONS = [:short, :long].freeze
  REGIONS = [:city, :region, :canton].freeze
  SINGLE_ACCOMPANIMENTS = [:man, :woman, :family, :kid].freeze
  GROUP_ACCOMPANIMENTS = [:sport, :creative, :music, :culture, :training, :german_course].freeze
  REJECTIONS = [:us, :her, :other].freeze
  TARGET_GROUPS = [:adults, :teenagers, :children].freeze
  GENDERS = [:female, :male].freeze

  def self.human_boolean(boolean)
    boolean ? I18n.t('simple_form.yes') : I18n.t('simple_form.no')
  end

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  private

  def default_state
    self.state ||= REGISTERED
  end
end
