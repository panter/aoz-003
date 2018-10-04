FactoryBot.define do
  factory :semester_feedback do
    association :author, factory: :user
    volunteer
    semester_process_volunteer
    goals 'Goals text'
    achievements 'Achievements text'
    future 'Future text'
    comments 'Comments text'
    association :semester_feedbackable, factory: :group_assignment
  end
end
