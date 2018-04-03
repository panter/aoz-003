FactoryBot.define do
  factory :event do
    kind 0
    title { FFaker::Lorem.sentence }
    description { FFaker::Lorem.paragraph }
    start_time { FFaker::Time.between(20.hours.ago, 4.hours.ago) }
    end_time { FFaker::Time.between(20.hours.ago, 4.hours.ago) }
    date { FFaker::Time.between(300.days.ago, 10.days.ago) }

    association :creator, factory: :user_fake_email

    trait :with_department do
      association :department
    end
  end
end
