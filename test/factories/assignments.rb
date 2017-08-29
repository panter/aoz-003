FactoryGirl.define do
  factory :assignment do
    client
    volunteer
    state 'suggested'
    association :creator, factory: :user
  end
end
