FactoryBot.define do
  factory :feedback do
    goals { Faker::Lorem.words(4) }
    achievements { Faker::Lorem.sentence }
    future { Faker::Lorem.sentence }
    comments { Faker::Lorem.paragraph }
    conversation false
    after(:build) do |feedback|
      if feedback.volunteer.present? && feedback.feedbackable.blank?
        feedback.volunteer.user = create(:user_volunteer) if feedback.volunteer.user.blank?
        feedback.feedbackable = create(:assignment, volunteer: feedback.volunteer)
      elsif feedback.volunteer.blank? && feedback.feedbackable.present?
        feedback.volunteer = feedback.feedbackable.volunteer
      elsif feedback.volunteer.blank? && feedback.feedbackable.blank?
        feedback.volunteer = create(:volunteer_with_user)
        feedback.feedbackable = create(:assignment, volunteer: feedback.volunteer)
      end
      feedback.author ||= feedback.volunteer&.user || create(:user_fake_email)
    end
  end
end
