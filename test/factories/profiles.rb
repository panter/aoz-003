FactoryGirl.define do
  factory :profile do
    flexible false
    morning false
    afternoon false
    evening true
    workday true
    weekend false

    association :contact
  end
end
