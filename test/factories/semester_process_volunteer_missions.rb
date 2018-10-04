FactoryBot.define do
  factory :semester_process_volunteer_mission do
    semester_process_volunteer

    after(:build) do |spvm|
      if spvm.assignment.blank?
        spvm.group_assignment ||= FactoryBot.build(:group_assignment,
          volunteer: spvm.semester_process_volunteer.volunteer)
      end
    end

  end
end
