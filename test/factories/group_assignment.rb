FactoryBot.define do
  factory :group_assignment do
    period_start { FFaker::Time.between(200.days.ago, 5.days.ago) }
    period_end { nil }

    trait :leading do
      responsible { true }
    end

    after(:build) do |group_assignment|
      group_assignment.volunteer = create(:volunteer_with_user) if group_assignment.volunteer.blank?
      group_assignment.group_offer = create(:group_offer) if group_assignment.group_offer.blank?
    end
  end
end
