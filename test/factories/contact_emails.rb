FactoryGirl.define do
  factory :contact_email do
    sequence :body { |n| "noone#{n}@example.com" }
    trait :with_label do
      label ['home', 'work'].sample
    end
  end
end
