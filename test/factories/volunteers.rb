FactoryGirl.define do
  factory :volunteer do
    first_name 'Volunteer'
    last_name 'Volunteer'
    email 'volunteer@example.com'

    trait :with_language_skills do
      language_skills do |language_skill|
        1.step(2).to_a.map { |_n| language_skill.association(:language_skill) }
      end
    end
  end
end
