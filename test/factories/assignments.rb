FactoryGirl.define do
  factory :assignment do
    association :client, strategy: :create
    association :volunteer, strategy: :create
    association :creator, strategy: :create
  end
end
