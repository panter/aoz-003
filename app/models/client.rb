class Client < ApplicationRecord
  belongs_to :user

  has_many :language_skills, as: :languageable, dependent: :destroy
  accepts_nested_attributes_for :language_skills, allow_destroy: true

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :schedules, as: :scheduleable, dependent: :destroy
  accepts_nested_attributes_for :schedules

  validates :first_name, :last_name, presence: true
end
