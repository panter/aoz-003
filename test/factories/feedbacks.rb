FactoryBot.define do
  factory :feedback do
    association :feedbackable, factory: :assignment
    volunteer
    association :author, factory: :user
    goals { Faker::Lorem.words(4) }
    achievements { Faker::Lorem.sentence }
    future { Faker::Lorem.sentence }
    comments { Faker::Lorem.paragraph }
    conversation false
  end
end
