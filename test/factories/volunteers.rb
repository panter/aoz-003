FactoryGirl.define do
  factory :volunteer do
    association :contact, strategy: :build
    state 'registered'
    sequence :date_of_birth { Time.zone.now.to_date - rand(5000..20_000) }
    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end
  end
end
