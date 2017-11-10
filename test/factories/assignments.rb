FactoryBot.define do
  factory :assignment do
    client
    volunteer
    association :creator, factory: :user
    period_start { Faker::Date.between(500.days.ago, 200.days.ago) }
    period_end { [nil, Faker::Date.between(199.days.ago, 10.days.ago)].sample }

    trait :active_this_year do
      period_start { Time.zone.today.beginning_of_year + 1 }
      period_end nil
    end

    trait :active_last_year do
      period_start { 1.year.ago.to_date }
      period_end { 1.year.ago.to_date.end_of_year - 2 }
    end

    trait :blank_period do
      period_start { nil }
      period_end { nil }
    end

    factory :assignment_blank_period, traits: [:blank_period]
  end
end
