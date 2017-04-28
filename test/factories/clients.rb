FactoryGirl.define do
  factory :client do
    user
    sequence :first_name { |n| "first_name#{n}" }
    sequence :last_name { |n| "last_name#{n}" }

    trait :with_relatives do
      relatives do |relative|
        1.step(2).to_a.map { |_n| relative.association(:relative) }
      end
    end

    trait :with_language_skills do
      language_skills do |language_skill|
        1.step(2).to_a.map { |_n| language_skill.association(:language_skill) }
      end
    end
  end
end
