FactoryBot.define do
  factory :assignment do
    client
    volunteer
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

    trait :active do
      period_start { 10.days.ago }
      period_end nil
    end

    trait :inactive do
      period_start { 10.days.ago }
      period_end { 5.days.ago }
    end

    trait :blank_period do
      period_start { nil }
      period_end { nil }
    end

    after(:build) do |assignment|
      assignment.creator ||= create(:user_fake_email)
    end

    factory :assignment_blank_period, traits: [:blank_period]
    factory :assignment_active, traits: [:active]
    factory :assignment_inactive, traits: [:inactive]
  end
end
