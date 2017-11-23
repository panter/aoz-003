FactoryBot.define do
  factory :trial_feedback do
    association :feedbackable, factory: :assignment
    volunteer
    association :author, factory: :user
    body { Faker::Lorem.paragraph }
  end
end
