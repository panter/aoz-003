FactoryBot.define do
  factory :client_notification do
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    user
    active true

    trait :faker_text do
      body { FFaker::Lorem.paragraph }
    end

    factory :client_notification_seed, traits: [:faker_text]
  end
end
