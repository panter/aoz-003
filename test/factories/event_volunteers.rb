FactoryBot.define do
  factory :event_volunteer do

    association :creator, factory: :user_fake_email

    association :volunteer, factory: :volunteer_with_user
    association :event, factory: :event
  end
end
