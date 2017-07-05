class LanguageSkill < ApplicationRecord
  belongs_to :languageable, polymorphic: true, optional: true

  def self.language_level_collection
    [:native_speaker, :fluent, :good, :basic]
  end

  def language_name
    return '' if language.blank?
    I18nData.languages(I18n.locale)[language]
  end

  def full_language_skills
    level_human = I18n.t(level, scope: [:language_level])
    [language_name, level_human].reject(&:blank?).join(', ')
  end
end
