FactoryBot.define do
  factory :semester_process_volunteer do
    volunteer
    semester_process
    notes { ['some note', 'another note'] }

    transient do
      add_mission { false }
      mission_count { 0 }
      mission_type { :assignment }
      add_feedbacks { false }
      add_hours { false }
      add_mail { false }
    end

    trait :with_mail do
      transient do
        add_mail { true }
      end
    end

    trait :with_mission do
      transient do
        add_mission { true }
        mission_count { 1 }
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

    after(:create) do |spv, ev|
      ev.mission_count.times do
        create(:semester_process_volunteer_mission, semester_process_volunteer: spv,
          mission: create(ev.mission_type || :assignment, volunteer: spv.volunteer))
      end

      if (ev.add_feedbacks || ev.add_hours) && spv.semester_process_volunteer_missions.none?
        create(:semester_process_volunteer_mission, semester_process_volunteer: spv,
          mission: create(ev.mission_type || :assignment, volunteer: spv.volunteer))
      end

      if ev.add_feedbacks
        spv.semester_process_volunteer_missions.map do |sem_proc_mission|
          create(:semester_feedback, mission: sem_proc_mission.mission,
            semester_process_volunteer: spv)
        end
      end

      if ev.add_hours
        spv.semester_process_volunteer_missions.map do |sem_proc_mission|
          create(:hour, hourable: sem_proc_mission.mission)
        end
      end

      if ev.add_mail
        create(:semester_process_mail, semester_process_volunteer: spv, kind: 'mail',
          sent_by: spv.semester_process.creator)
      end
    end
  end
end
