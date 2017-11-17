FactoryBot.define do
  factory :client_notification do
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    user
    active true

    trait :fakered do
      body { Faker::HeyArnold.quote }
    end

    factory :client_notification_seed, traits: [:fakered]
  end
end
