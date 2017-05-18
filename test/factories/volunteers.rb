FactoryGirl.define do
  factory :volunteer do
    first_name 'Volunteer'
    last_name 'Volunteer'
    email 'volunteer@example.com'

    trait :with_relatives do
      relatives do |relative|
        Array.new(2) { relative.association(:relative) }
      end
    end

    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end
  end
end
