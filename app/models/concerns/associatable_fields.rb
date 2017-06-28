module AssociatableFields
  extend ActiveSupport::Concern

  included do
    has_many :language_skills, as: :languageable, dependent: :destroy
    accepts_nested_attributes_for :language_skills, allow_destroy: true

    has_many :schedules, as: :scheduleable, dependent: :destroy
    accepts_nested_attributes_for :schedules
  end
end
