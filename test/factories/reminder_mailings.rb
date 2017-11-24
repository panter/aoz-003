FactoryBot.define do
  factory :reminder_mailing do
    association :creator, factory: :user_fake_email
    body { Faker::Lorem.paragraph }
    subject { Faker::Lorem.sentence }
    kind 'probation_period'
    after(:build) do |reminder_mailing|
      volunteer = create(:volunteer_with_user)
      assignment = create(:assignment, volunteer: volunteer, period_start: 6.weeks.ago.to_date + 5)
      reminder_mailing.reminder_mailing_volunteers << ReminderMailingVolunteer.new(volunteer: volunteer, reminder_mailable: assignment, selected: '1')
    end
  end
end
