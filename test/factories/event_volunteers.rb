FactoryBot.define do
  factory :event_volunteer do

    association :creator, factory: :user

    association :volunteer
    association :event, factory: :event
  end
end
