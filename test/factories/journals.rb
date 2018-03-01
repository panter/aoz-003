FactoryBot.define do
  factory :journal do
    sequence :body do |n|
      " Bogus_text_body_#{n}" * 30
    end
    user
    category { Journal::CATEGORIES.sample }

    trait :faker_text do
      body { FFaker::Lorem.paragraph }
    end

    factory :journal_seed, traits: [:faker_text]
  end
end
