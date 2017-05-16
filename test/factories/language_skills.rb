FactoryGirl.define do
  factory :language_skill do
    language I18nData.languages.to_a.sample.first
    level 'fluent'
  end
end
