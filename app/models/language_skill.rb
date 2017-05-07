class LanguageSkill < ApplicationRecord
  belongs_to :client

  LEVELS = ['native_speaker', 'fluent', 'good', 'basic'].freeze


  def language_name
    return '' if language.blank?
    I18nData.languages(I18n.locale)[language]
  end

  def self.level_collection
    LEVELS.map(&:to_sym)
  end
end
