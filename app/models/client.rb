class Client < ApplicationRecord
  belongs_to :user

  has_many :language_skills, dependent: :destroy
  accepts_nested_attributes_for :language_skills, allow_destroy: true

  has_many :relatives, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :schedules, dependent: :destroy
  accepts_nested_attributes_for :schedules

  GENDERS = ['female', 'male'].freeze
  STATES = ['registered', 'reserved', 'active', 'finished', 'rejected'].freeze
  PERMITS = ['L', 'B'].freeze

  validates :first_name, :last_name, presence: true
  validates :state, inclusion: { in: STATES }

  def nationality_name
    return '' if nationality.blank?
    c = ISO3166::Country[nationality]
    c.translations[I18n.locale.to_s] || c.name
  end

  def self.gender_collection
    GENDERS.map(&:to_sym)
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end

  def self.permit_collection
    PERMITS.map(&:to_sym)
  end
end
