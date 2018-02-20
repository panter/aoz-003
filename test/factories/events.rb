FactoryBot.define do
  factory :event do
    kind 0
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }

    association :creator, factory: :user_fake_email

    trait :with_department do
      association :department
    end

  end
end
