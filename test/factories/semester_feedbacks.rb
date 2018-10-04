FactoryBot.define do
  factory :semester_feedback do
    semester_process_volunteer
    goals 'Goals text'
    achievements 'Achievements text'
    future 'Future text'
    comments 'Comments text'

    trait :with_assignment do
      association :assignment
    end

    trait :with_group_assignment do
      association :group_assignment
    end

    after(:build) do |sem_fb|
      if sem_fb.assignment.blank?
        sem_fb.group_assignment ||= FactoryBot.build(:group_assignment, volunteer: sem_fb.volunteer)
      end
      sem_fb.volunteer = sem_fb.semester_process_volunteer.volunteer
      sem_fb.author = sem_fb.volunteer.user
    end
  end
end
