FactoryBot.define do
  factory :semester_process do
    association :creator, factory: :user
    mail_subject_template 'mail subject template'
    mail_body_template 'mail body template'
    mail_posted_at { Time.zone.local(2018, 6, 10) }
    association :mail_posted_by, factory: :user

    semester { Time.zone.local(2017, 12, 1).beginning_of_day..Time.zone.local(2018, 5, 30).end_of_month }
  end
end
