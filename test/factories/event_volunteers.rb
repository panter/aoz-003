FactoryBot.define do
  factory :event_volunteer do

    association :creator, factory: :user_fake_email

    after(:build) do |event_volunteer|
      volunteer = create(:volunteer_with_user)
      event = create(:event)
      event.event_volunteer << EventVolunteer.new(event_volunteer: volunteer)
    end
  end
end
