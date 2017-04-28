FactoryGirl.define do
  factory :language_skill do
    client
    language I18nData.languages.to_a.sample.first
    level 'fluent'
  end
end
