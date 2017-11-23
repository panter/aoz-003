FactoryBot.define do
  factory :trial_feedback do
    body 'MyText'
    volunteer
    association :author, factory: :user
    association :reviewer, factory: :user
  end
end
