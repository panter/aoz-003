FactoryBot.define do
  factory :assignment do
    client
    association :volunteer
    association :creator, factory: :user
    period_start { [nil, FFaker::Time.between(500.days.ago, 200.days.ago)].sample }
    period_end { nil }

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

    factory :assignment_blank_period, traits: [:blank_period]
    factory :assignment_active, traits: [:active]
    factory :assignment_inactive, traits: [:inactive]

    factory :terminated_assignment do
      period_end { 4.days.ago }
      termination_submitted_at { 3.days.ago }
      termination_verified_at { 2.days.ago }
      association :period_end_set_by, factory: :user
      after(:build) do |assignment|
        assignment.volunteer ||= create(:volunteer)
        assignment.termination_submitted_by = assignment.volunteer.user
        assignment.termination_verified_by = assignment.period_end_set_by
      end
      after(:create, &:create_log_of_self)
    end
  end
end
