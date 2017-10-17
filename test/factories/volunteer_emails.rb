FactoryGirl.define do
  factory :volunteer_email do
    sequence :subject { |n| "demo subject_#{n}" }
    sequence :title { |n| "demo title_#{n}" }
    sequence :body { |n| "the demonstration rar ra ra body_#{n}" }
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
