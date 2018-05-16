FactoryBot.define do
  factory :language_skill do
    language { I18n.t('language_names').keys.sample }
    level 'fluent'
  end
end
