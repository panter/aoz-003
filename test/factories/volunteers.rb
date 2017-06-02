FactoryGirl.define do
  factory :volunteer do
    contact do |c|
      c.association(:contact)
    end
    state 'registered'

    trait :with_relatives do
      relatives do |relative|
        Array.new(2) { relative.association(:relative) }
      end
    end
    sequence :date_of_birth { Time.zone.now.to_date - rand(5000..20_000) }
    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end
  end
end
