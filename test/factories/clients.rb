FactoryGirl.define do
  factory :client do
    sequence :firstname { |n| "firstname#{n}" }
    sequence :lastname { |n| "lastname#{n}" }
    user
  end
end
