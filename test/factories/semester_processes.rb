FactoryBot.define do
  factory :semester_process do
    association :creator, factory: :user

    period_start { Time.zone.local(2017, 12, 1).beginning_of_day }
    period_end { Time.zone.local(2018, 5, 30).end_of_month }
  end
end
