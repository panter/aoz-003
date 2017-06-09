class Volunteer < ApplicationRecord
  include AssociatableFields
  include GenderCollection

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  acts_as_paranoid

  before_save :default_state

  REGISTERED = 'registered'.freeze
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze
  INACTIVE = 'inactive'.freeze
  RESIGNED = 'resigned'.freeze
  STATES_FOR_REVIEWED = [ACCEPTED, REJECTED, INACTIVE, RESIGNED].freeze
  STATES = [REGISTERED] + STATES_FOR_REVIEWED

  belongs_to :user, optional: true
  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :state, inclusion: { in: STATES }
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  validates :email, uniqueness: true

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

  private

  def default_state
    self.state ||= REGISTERED
  end
end
