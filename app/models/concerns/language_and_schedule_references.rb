module LanguageAndScheduleReferences
  extend ActiveSupport::Concern

  included do
    has_many :language_skills, as: :languageable, dependent: :destroy
    accepts_nested_attributes_for :language_skills, allow_destroy: true

    delegate :native_languages, to: :language_skills
    delegate :foreign_languages, to: :language_skills
    delegate :native_language, to: :language_skills

    has_many :schedules, as: :scheduleable, dependent: :destroy
    accepts_nested_attributes_for :schedules

    before_validation :build_schedules
    validate :validate_schedule_count

    def validate_schedule_count
      if schedules.size < Schedule::CORRECT_SIZE
        errors.add(:schedules, 'not enough')
      elsif schedules.size > Schedule::CORRECT_SIZE
        errors.add(:schedules, 'too many')
      end
    end

    def build_schedules
      schedules << Schedule.build if schedules.size.zero?
    end
  end
end
