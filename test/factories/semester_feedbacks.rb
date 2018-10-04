FactoryBot.define do
  factory :semester_feedback do
    association :author, factory: :user
    semester_process_volunteer
    volunteer
    goals 'Goals text'
    achievements 'Achievements text'
    future 'Future text'
    comments 'Comments text'

    after(:build) do |sem_fb|
      if sem_fb.assignment.blank?
        sem_fb.group_assignment ||= FactoryBot.build(:group_assignment)
      end
    end
  end
end
