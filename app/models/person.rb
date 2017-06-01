class Person < ApplicationRecord
  belongs_to :personable, polymorphic: true, optional: true

  has_many :language_skills, as: :languageable, dependent: :destroy
  accepts_nested_attributes_for :language_skills, allow_destroy: true

  has_and_belongs_to_many :relative
  accepts_nested_attributes_for :relative

  has_many :schedules, dependent: :destroy
  accepts_nested_attributes_for :schedules

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :first_name, :last_name, presence: true

  GENDERS = ['female', 'male'].freeze

  def self.gender_collection
    GENDERS.map(&:to_sym)
  end

  def self.build
    Person.new(&:build_contact)
  end
end
