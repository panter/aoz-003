FactoryGirl.define do
  factory :department do
    association :contact, factory: :contact_department
  end
end
