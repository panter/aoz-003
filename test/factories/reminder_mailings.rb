FactoryBot.define do
  factory :reminder_mailing do
    association :creator, factory: :user_fake_email
    body { FFaker::Lorem.paragraph }
    subject { FFaker::Lorem.sentence }

    trait :half_year do
      kind { 0 }
      body { FFaker::Lorem.paragraph }
      subject { FFaker::Lorem.sentence }
    end

    trait :trial_period do
      kind { 1 }
      body { FFaker::Lorem.paragraph }
      subject { FFaker::Lorem.sentence }
    end

    trait :termination do
      kind { 2 }
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
