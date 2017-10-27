FactoryGirl.define do
  factory :journal do
    sequence :body { |n| " Bogus_text_body_#{n}" * 30 }
    user
    category { Journal::CATEGORIES.sample }

    trait :faker_text do
      body { Faker::Hipster.paragraph }
    end

    factory :journal_seed, traits: [:faker_text]
  end
end
