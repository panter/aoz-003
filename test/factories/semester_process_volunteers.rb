FactoryBot.define do
  factory :semester_process_volunteer do
    volunteer
    semester_process
    notes { ['some note', 'another note'] }

    transient do
      add_mission { false }
      mission_count { 1 }
      mission_type { :assignment }
      add_feedbacks { false }
      add_hours { false }
    end

    trait :with_mission do
      transient do
        add_mission { true }
      end
    end

    trait :with_feedbacks do
      transient do
        add_feedbacks { true }
      end
    end

    trait :with_hours do
      transient do
        add_hours { true }
      end
    end

    after(:create) do |spv, evaluator|
      (evaluator.mission_count || 1).times do
        create(:semester_process_volunteer_mission, semester_process_volunteer: spv,
          mission: create(evaluator.mission_type || :assignment, volunteer: spv.volunteer))
      end

      if evaluator.add_feedbacks
        spv.semester_process_volunteer_missions.map do |sem_proc_vol_mission|
          create(:semester_feedback, mission: sem_proc_vol_mission.mission,
            semester_process_volunteer: spv)
        end
      end

      if evaluator.add_hours
        spv.semester_process_volunteer_missions.map do |sem_proc_vol_mission|
          create(:hour, hourable: sem_proc_vol_mission.mission, volunteer: spv.volunteer,
            semester_process_volunteer: spv)
        end
      end
    end
  end
end
