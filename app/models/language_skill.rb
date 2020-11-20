class LanguageSkill < ApplicationRecord
  belongs_to :languageable, polymorphic: true, optional: true

  validates :level, presence: true

  LANGUAGE_LEVELS = [:native_speaker, :basic, :fluent, :good].freeze

  scope :german_first, (-> { order(Arel.sql("CASE WHEN language = 'DE' THEN 1 ELSE 2 END")) })

  scope :german, (-> { where(language: 'DE') })
  scope :native, (-> { where(level: 'native_speaker') })
  scope :native_languages, (-> { native.german_first })
  scope :foreign_languages, lambda {
    return none unless native_language.id

    where.not(id: native_language.id)
  }

  class << self
    def languages
      @languages ||= I18n.t('language_names').merge(I18n.t('language_names_customizations'))
        .map { |key, lang| [lang, key.to_s] }.sort
    end

    def native_language
      native_languages.first || LanguageSkill.new
    end

    def language_name(language)
      return '' if language.blank?

      I18n.t("language_names.#{language}")
    end

    def native_and_human_readable
      german_first.map(&:full_language_skills)
    end
  end

  def language_name
    self.class.language_name(language)
  end

  def full_language_skills
    level_human = level? ? I18n.t(level, scope: [:language_level]) : ''
    [language_name, level_human].reject(&:blank?).join(', ') if language?
  end
end
