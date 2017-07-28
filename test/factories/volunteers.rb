FactoryGirl.define do
  factory :volunteer do
    state 'registered'
    sequence :birth_year { Time.zone.now.to_date - rand(5000..20_000) }
    contact
    salutation 'mrs'

    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end
  end
end
