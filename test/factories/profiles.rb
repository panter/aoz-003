FactoryGirl.define do
  factory :profile do
    user
    association :contact
    monday true
    tuesday true
    wednesday false
    thursday true
    friday false
  end
end
