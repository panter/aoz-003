module LanguageReferences
  extend ActiveSupport::Concern

  included do
    has_many :language_skills, as: :languageable, dependent: :destroy
    accepts_nested_attributes_for :language_skills, allow_destroy: true

    delegate :native_languages, to: :language_skills
    delegate :foreign_languages, to: :language_skills
    delegate :native_language, to: :language_skills
  end
end
