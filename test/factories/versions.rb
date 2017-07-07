FactoryGirl.define do
  factory :version do
    user
    association :contact

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
