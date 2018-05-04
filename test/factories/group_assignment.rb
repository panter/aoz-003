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

    factory :terminated_group_assignment do
      period_end { 4.days.ago }
      termination_submitted_at { 3.days.ago }
      termination_verified_at { 2.days.ago }
      association :period_end_set_by, factory: :user
      after(:build) do |group_assignment|
        group_assignment.volunteer ||= create(:volunteer_with_user)
        group_assignment.termination_submitted_by = group_assignment.volunteer.user
        group_assignment.termination_verified_by = group_assignment.period_end_set_by
        group_assignment.group_offer ||= create(:group_offer)
      end
      after(:create, &:create_log_of_self)
    end
  end
end
