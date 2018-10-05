FactoryBot.define do
  factory :semester_process_volunteer_mission do
    semester_process_volunteer

    transient do
      add_mission { true }
    end

    # feedback has to be created with mission, and then the resulting instance has it removed
    # because otherwise test/models/factory_test.rb will fail
    trait :no_mission do
      transient do
        add_mission { false }
      end
    end

    after(:build) do |spvm|
      if spvm.assignment.blank?
        spvm.group_assignment ||= FactoryBot.build(:group_assignment,
          volunteer: spvm.semester_process_volunteer.volunteer)
      end
    end

    after(:create) do |spvm, evl|
      unless evl.add_mission
        spvm.group_assignment = nil
        spvm.assignment = nil
      end
    end
  end
end
