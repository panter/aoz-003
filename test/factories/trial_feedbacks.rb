FactoryBot.define do
  factory :trial_feedback do
    association :trial_feedbackable, factory: :assignment
    body { FFaker::Lorem.paragraph }

    after(:build) do |trial_feedback|
      if trial_feedback.volunteer.present? && trial_feedback.trial_feedbackable.blank?
        trial_feedback.volunteer.user ||= create(:user_volunteer)
        trial_feedback.trial_feedbackable = create(:assignment, volunteer: trial_feedback.volunteer,
          period_end: nil, period_start: 6.weeks.ago)
      elsif trial_feedback.volunteer.blank? && trial_feedback.trial_feedbackable.present?
        trial_feedback.volunteer = trial_feedback.trial_feedbackable.volunteer
      elsif trial_feedback.volunteer.blank? && trial_feedback.trial_feedbackable.blank?
        trial_feedback.volunteer = create(:volunteer)
        trial_feedback.trial_feedbackable = create(:assignment, period_end: nil,
          period_start: 6.weeks.ago, volunteer: trial_feedback.volunteer)
      end
      trial_feedback.author ||= trial_feedback.volunteer&.user || create(:user)
    end
  end
end
