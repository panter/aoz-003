FactoryGirl.define do
  factory :contact_phone do
    sequence :body { |n| "+41 44 999 99 9#{n}" }
    trait :with_label do
      label ['fax', 'home', 'work'].sample
    end
  end
end
