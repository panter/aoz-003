FactoryBot.define do
  factory :trial_feedback do
    association :trial_feedbackable, factory: :assignment
    body { Faker::Lorem.paragraph }

    after(:build) do |trial_feedback|
      trial_feedback.volunteer ||= trial_feedback.trial_feedbackable.volunteer
      trial_feedback.author ||= trial_feedback.volunteer.user || create(:user_fake_email)
    end
  end
end
