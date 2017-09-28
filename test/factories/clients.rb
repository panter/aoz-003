FactoryGirl.define do
  factory :client do
    association :user
    association :contact

    trait :zuerich do
      association :contact, factory: :contact_zuerich
    end

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

    factory :client_z, traits: [:zuerich]
  end
end
