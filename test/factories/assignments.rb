FactoryGirl.define do
  factory :assignment do
    client
    volunteer

    association :creator, factory: :user
  end
end
