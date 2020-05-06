FactoryBot.define do
  factory :trial_period do
    end_date { 1.month.from_now.to_date }

    trait :verified do
      end_date { 1.month.ago.to_date }
      verified_at { Time.zone.now }
      verified_by { create(:superadmin) }
    end

    after :build do |trial_period, evl|
      if evl.assignment
        trial_period.assignment = create(:assignment)
      elsif evl.group_assignment
        trial_period.group_assignment = create(:group_assignment)
      end
    end
  end
end
