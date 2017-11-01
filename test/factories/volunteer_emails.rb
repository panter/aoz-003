FactoryBot.define do
  factory :volunteer_email do
    sequence :subject do |n|
      "demo subject_#{n}"
    end
    sequence :title do |n|
      "demo title_#{n}"
    end
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    user
    active true

    trait :fakered do
      subject { Faker::Hobbit.quote }
      title { Faker::Hobbit.quote }
      body { Faker::HeyArnold.quote }
    end

    factory :volunteer_email_seed, traits: [:fakered]
  end
end
