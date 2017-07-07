class Volunteer < ApplicationRecord
  include LanguageAndScheduleReferences
  include GenderCollection

  acts_as_paranoid
  before_save :default_state

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  belongs_to :user, optional: true

  belongs_to :registrar, optional: true,
    class_name: 'User', foreign_key: 'registrar_id'

  has_attached_file :avatar, styles: { thumb: '100x100#' }

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
  STATES = [REGISTERED] + STATES_FOR_REVIEWED

  has_one :assignment
  has_one :client, through: :assignments

  belongs_to :user, optional: true
  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :contact, presence: true
  validates :state, inclusion: { in: STATES }
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  def self.state_collection
    STATES.map(&:to_sym)
  end

  def self.state_collection_for_reviewed
    STATES_FOR_REVIEWED.map(&:to_sym)
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

  def self.duration_collection
    [:short, :long]
  end

  def self.region_collection
    [:city, :region, :canton]
  end

  def self.single_accompaniment
    [:man, :woman, :family, :kid]
  end

  def self.group_accompaniment
    [:sport, :creative, :music, :culture, :training, :german_course]
  end

  def self.human_boolean(boolean)
    boolean ? I18n.t('simple_form.yes') : I18n.t('simple_form.no')
  end

  def self.rejection_collection
    [:us, :her, :other]
  end

  def self.target_group
    [:adults, :teenagers, :children]
  end

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  def self.without_clients
    Volunteer.includes(:assignment).where(assignments: { volunteer_id: nil })
  end

  private

  def default_state
    self.state ||= REGISTERED
  end
end
