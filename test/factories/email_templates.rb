FactoryBot.define do
  factory :email_template do
    kind 0
    sequence :subject do |n|
      "demo subject_#{n}"
    end
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    active true

    trait :fakered do
      subject { Faker::Hobbit.quote }
      body { Faker::HeyArnold.quote }
    end

    factory :email_template_seed, traits: [:fakered]
  end
end
