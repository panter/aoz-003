class LanguageSkill < ApplicationRecord
  belongs_to :client

  def language_name
    return '' if language.blank?
    I18nData.languages[language]
  end
end
