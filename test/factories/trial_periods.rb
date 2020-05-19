FactoryBot.define do
  factory :trial_period do
    end_date { 1.month.from_now.to_date }

    trait :verified do
      end_date { 1.month.ago.to_date }
      verified_at { Time.zone.now }
      verified_by { create(:superadmin) }
    end

    trait :with_note do
      notes { FFaker::Lorem.paragraph }
    end

    after :build do |trial_period|
      trial_period.trial_period_mission = create(:assignment) unless trial_period.trial_period_mission.present?
    end
  end
end
