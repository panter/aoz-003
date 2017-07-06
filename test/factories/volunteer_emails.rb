FactoryGirl.define do
  factory :volunteer_email do
    sequence :subject { |n| "demo subject_#{n}" }
    sequence :title { |n| "demo title_#{n}" }
    sequence :body { |n| "the demonstration rar ra ra body_#{n}" }
    user
    active true
  end
end
