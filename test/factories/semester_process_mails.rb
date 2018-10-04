FactoryBot.define do
  factory :semester_process_mail do
    semester_process_volunteer
    association :sent_by, factory: :user
    sent_at { Time.zone.local(2018, 8, 12) }
    subject 'mail subject'
    body 'Mail body'
  end
end
