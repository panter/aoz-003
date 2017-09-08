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

    trait :with_assignment do
      assignments do |assignment|
        [assignment.association(:assignment, period_start: 300.days.ago, period_end: 20.days.ago)]
      end
    end
  end
end
