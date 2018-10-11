FactoryBot.define do
  factory :semester_process do
    association :creator, factory: :user
    mail_subject_template 'mail subject template'
    mail_body_template 'mail body template'
    semester { Time.zone.local(2017, 12, 1).beginning_of_day..Time.zone.local(2018, 5, 30).end_of_month }

    transient do
      build_volunteers { false }
    end

    trait :with_volunteers do
      transient do
        build_volunteers { true }
        volunteers_count { 1 }
      end
    end

    after(:create) do |sem_proc, evaluator|
      if evaluator.build_volunteers
        evaluator.volunteers_count.times do
          create :semester_process_volunteer, :with_mission, semester_process: sem_proc
        end
      end
    end
  end
end
