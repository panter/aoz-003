FactoryGirl.define do
  factory :profile do
    association :contact, strategy: :build
    monday true
    tuesday true
    wednesday false
    thursday true
    friday false
  end
end
