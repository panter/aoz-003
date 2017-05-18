FactoryGirl.define do
  factory :contact_email do
    sequence :body { |n| "noone#{n}@example.com" }
    trait :with_label do
      label 'work'
    end
  end
end
