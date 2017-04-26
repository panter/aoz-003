class Client < ApplicationRecord
  belongs_to :user

  has_many :language_skills, dependent: :destroy
  accepts_nested_attributes_for :language_skills, allow_destroy: true

  has_many :relatives, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :schedules, dependent: :destroy
  accepts_nested_attributes_for :schedules

  validates :firstname, :lastname, presence: true
end
