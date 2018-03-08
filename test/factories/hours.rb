FactoryBot.define do
  factory :hour do
    meeting_date { FFaker::Time.between(300.days.ago, 10.days.ago) }
    hours 2
    minutes 15
    association :hourable, factory: :assignment
    activity { FFaker::CheesyLingo.sentence }
    comments { FFaker::CheesyLingo.paragraph }

    after(:build) do |hour|
      hour.volunteer = hour.hourable.volunteer if hour.volunteer.blank?
    end
  end
end
