FactoryGirl.define do
  factory :department do
    association :contact, strategy: :build
  end
end
