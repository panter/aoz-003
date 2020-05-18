FactoryBot.define do
  factory :semester_process_mail do
    semester_process_volunteer
    sent_at { Time.zone.local(2018, 8, 12) }
    subject { 'mail subject' }
    body { 'Mail body' }
    kind { 'mail' }

    trait :as_reminder do
      kind { 'reminder' }
    end

    after(:build) do |sem_proc_mail|
      sem_proc_mail.sent_by = sem_proc_mail.semester_process_volunteer.semester_process.creator
    end
  end
end
