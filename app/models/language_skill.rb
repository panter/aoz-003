class LanguageSkill < ApplicationRecord
  belongs_to :languageable, polymorphic: true, optional: true

  validates :level, presence: true

  LANGUAGE_LEVELS = [:native_speaker, :basic, :fluent, :good].freeze

  scope :german_first, (-> { order("CASE WHEN language = 'DE' THEN 1 ELSE 2 END") })

  scope :german, (-> { where(language: 'DE') })
  scope :native, (-> { where(level: 'native_speaker') })
  scope :native_languages, (-> { native.german_first })
  scope :foreign_languages, lambda {
    return none unless native_language.id
    where.not(id: native_language.id)
  }

  def self.native_language
    native_languages.first || LanguageSkill.new
  end

  def self.language_name(language)
    return '' if language.blank?
    return 'Dari' if language == 'DR'
    return 'Farsi' if language == 'FS'
    I18nData.languages(I18n.locale)[language]
  end

  def language_name
    self.class.language_name(language)
  end

  def full_language_skills
    level_human = level? ? I18n.t(level, scope: [:language_level]) : ''
    [language_name, level_human].reject(&:blank?).join(', ') if language?
  end
end
