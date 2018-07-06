def create_reminder_mailable(reminder_mailing, volunteer)
  case reminder_mailing.kind
  when 'half_year'
    create(:assignment, volunteer: volunteer, creator: reminder_mailing.creator,
      period_start: FFaker::Time.between(6.months.ago, 12.months.ago))
  when 'trial_period'
    create(:assignment, volunteer: volunteer, creator: reminder_mailing.creator,
      period_start: FFaker::Time.between(6.weeks.ago, 8.weeks.ago))
  when 'termination'
    start_date = FFaker::Time.between(1.year.ago, 2.years.ago)
    create(:assignment, volunteer: volunteer, creator: reminder_mailing.creator,
      period_start: start_date,
      period_end: FFaker::Time.between(start_date + 100.days, 2.days.ago))
  end
end

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
      if reminder_mailing.reminder_mailing_volunteers.any?
        reminder_mailing.reminder_mailing_volunteers.each { |rmv| rmv.picked = true }
      else
        volunteer = create(:volunteer)
        assignment = create_reminder_mailable(reminder_mailing, volunteer)
        reminder_mailing.reminder_mailing_volunteers << ReminderMailingVolunteer.new(
          volunteer: volunteer, reminder_mailable: assignment, picked: true
        )
      end
    end
  end
end
