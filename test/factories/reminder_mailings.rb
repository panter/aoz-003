FactoryBot.define do
  factory :reminder_mailing do
    association :creator, factory: :user
    body { FFaker::Lorem.paragraph }
    subject { FFaker::Lorem.sentence }

    trait :half_year do
      kind { ReminderMailing.kinds[:half_year] }
      body { FFaker::Lorem.paragraph }
      subject { FFaker::Lorem.sentence }
    end

    trait :trial_period do
      kind { ReminderMailing.kinds[:trial_period] }
      body { FFaker::Lorem.paragraph }
      subject { FFaker::Lorem.sentence }
    end

    trait :termination do
      kind { ReminderMailing.kinds[:termination] }
      body { FFaker::Lorem.paragraph }
      subject { FFaker::Lorem.sentence }
    end

    after(:build) do |reminder_mailing|
      volunteer = create(:volunteer_with_user)
      assignment = create(:assignment, volunteer: volunteer, period_start: 6.weeks.ago.to_date + 5)
      reminder_mailing.reminder_mailing_volunteers << ReminderMailingVolunteer.new(
        volunteer: volunteer, reminder_mailable: assignment, picked: true)
    end
  end
end
