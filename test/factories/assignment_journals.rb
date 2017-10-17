FactoryGirl.define do
  factory :assignment_journal do
    assignment
    volunteer
    association :author, factory: :user
    goals { Faker::Lorem.words(4) }
    achievements { Faker::Lorem.sentence }
    future { Faker::Lorem.sentence }
    comments { Faker::Lorem.paragraph }
    conversation false
  end
end
