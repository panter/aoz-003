FactoryBot.define do
  factory :hour do
    meeting_date { Faker::Date.between(300.days.ago, 10.days.ago) }
    hours 2
    minutes 15
    association :hourable, factory: :assignment
    activity { Faker::DrWho.quote }
    comments { Faker::ChuckNorris.fact }

    after(:build) do |hour|
      hour.volunteer ||= hour.hourable.volunteer
    end
  end
end
