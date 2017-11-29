FactoryBot.define do
  factory :trial_feedback do
    association :trial_feedbackable, factory: :assignment
    volunteer
    association :author, factory: :user
    body { Faker::Lorem.paragraph }
  end
end
