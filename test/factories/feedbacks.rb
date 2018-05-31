FactoryBot.define do
  factory :feedback do
    association :feedbackable, factory: :assignment
    volunteer
    association :author, factory: :user
    goals { FFaker::Lorem.words(4).join(', ') }
    achievements { FFaker::Lorem.sentence }
    future { FFaker::Lorem.sentence }
    comments { FFaker::Lorem.paragraph }
    conversation false
    after(:build) do |feedback|
      if feedback.volunteer.present? && feedback.feedbackable.blank?
        feedback.volunteer.user = create(:user_volunteer) if feedback.volunteer.user.blank?
        feedback.feedbackable = create(:assignment, volunteer: feedback.volunteer)
      elsif feedback.volunteer.blank? && feedback.feedbackable.present?
        feedback.volunteer = feedback.feedbackable.volunteer
      elsif feedback.volunteer.blank? && feedback.feedbackable.blank?
        feedback.volunteer = create(:volunteer)
        feedback.feedbackable = create(:assignment, volunteer: feedback.volunteer)
      end
      feedback.author ||= feedback.volunteer&.user || create(:user)
    end
  end
end
