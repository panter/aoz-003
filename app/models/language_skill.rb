class LanguageSkill < ApplicationRecord
  belongs_to :languageable, polymorphic: true, optional: true

  def language_name
    return '' if language.blank?
    I18nData.languages(I18n.locale)[language]
  end
end
