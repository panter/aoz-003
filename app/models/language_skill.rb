class LanguageSkill < ApplicationRecord
  belongs_to :languageable, polymorphic: true, optional: true

  scope :native_languages, lambda {
    where(level: 'native_speaker')
      .order("CASE WHEN language = 'DE' THEN 1 WHEN language != 'DE' THEN 2 END")
  }
  scope :foreign_languages, -> { where.not(id: native_languages.first&.id) }

  LANGUAGE_LEVELS = [:native_speaker, :fluent, :good, :basic].freeze

  def language_name
    return '' if language.blank?
    return 'Dari' if language == 'DR'
    return 'Farsi' if language == 'FS'
    I18nData.languages(I18n.locale)[language]
  end

  def full_language_skills
    level_human = level? ? I18n.t(level, scope: [:language_level]) : ''
    [language_name, level_human].reject(&:blank?).join(', ') if language?
  end
end
