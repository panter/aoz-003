FactoryBot.define do
  factory :event_volunteer do

    association :creator, factory: :user_fake_email

    after(:build) do |event_volunteer|
      event_volunteer.volunteer = create(:volunteer_with_user)
      event_volunteer.event = create(:event)
    end
  end
end
