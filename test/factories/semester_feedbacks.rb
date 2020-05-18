FactoryBot.define do
  factory :semester_feedback do
    semester_process_volunteer
    goals { 'Goals text' }
    achievements { 'Achievements text' }
    future { 'Future text' }
    comments { 'Comments text' }

    transient do
      add_mission { true }
    end

    # feedback has to be created with mission, and then the resulting instance has it removed
    # because otherwise test/models/factory_test.rb will fail
    trait :no_mission do
      add_mission { false }
    end

    trait :with_assignment do
      association :assignment
    end

    trait :with_group_assignment do
      association :group_assignment
    end

    after(:build) do |sem_fb, _evl|
      if sem_fb.assignment.blank?
        sem_fb.group_assignment ||= FactoryBot.build(:group_assignment, volunteer: sem_fb.volunteer)
      end
      sem_fb.volunteer = sem_fb.semester_process_volunteer.volunteer
      sem_fb.author = sem_fb.volunteer.user
      sem_fb.goals = sem_fb.semester_process_volunteer.semester_t
    end

    after(:create) do |sem_fb, evl|
      unless evl.add_mission
        sem_fb.group_assignment = nil
        sem_fb.assignment = nil
      end
    end
  end
end
