class LanguageSkill < ApplicationRecord
  belongs_to :languageable, polymorphic: true, optional: true

  LANGUAGE_LEVELS = [:native_speaker, :fluent, :good, :basic].freeze

  scope :native_languages, lambda {
    where(level: 'native_speaker')
      .order("CASE WHEN language = 'DE' THEN 1 ELSE 2 END")
  }

  scope :german, (-> { where(language: 'DE') })

  scope :foreign_languages, lambda {
    return none unless native_language.id
    where.not(id: native_language.id)
  }

  scope :lang_order, lambda {
    order("CASE WHEN language = 'DE' THEN 1 ELSE 2 END")
      .order("CASE WHEN level = 'native_speaker' THEN 3 ELSE 4 END")
  }

  def self.native_language
    native_languages.first || LanguageSkill.new
  end

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
