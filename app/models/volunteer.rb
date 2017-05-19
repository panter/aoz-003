class Volunteer < ApplicationRecord
  include AssociatableFields
  include FullName
  include GenderCollection
  include StateCollection

  acts_as_paranoid

  belongs_to :user, optional: true

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  # Volunteer state definition
  INTERESTED = 'interested'.freeze
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze
  INACTIVE = 'inactive'.freeze
  STATES_FOR_REVIEWED = [ACCEPTED, REJECTED, INACTIVE].freeze
  STATES = STATES_FOR_REVIEWED + [INTERESTED]

  def interested?
    state == Volunteer::INTERESTED
  end

  def rejected?
    state == Volunteer::REJECTED
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

  def self.state_collection
    STATES.map(&:to_sym)
  end

  def self.state_collection_for_reviewed
    STATES_FOR_REVIEWED.map(&:to_sym)
  end

  def self.rejection_collection
    [:us, :her, :other]
  end
end
