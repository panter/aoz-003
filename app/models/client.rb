class Client < ApplicationRecord
  belongs_to :user

  has_many :language_skills, dependent: :destroy
  accepts_nested_attributes_for :language_skills, allow_destroy: true

  has_many :relatives, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :schedules, dependent: :destroy
  accepts_nested_attributes_for :schedules

  validates :first_name, :last_name, presence: true

  def nationality_name
    return '' if nationality.blank?
    c = ISO3166::Country[nationality]
    c.translations[I18n.locale.to_s] || c.name
  end
end
