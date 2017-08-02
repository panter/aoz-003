FactoryGirl.define do
  factory :contact do
    sequence :first_name { |n| "first name #{n}" }
    sequence :last_name { |n| "last name #{n}" }
    street 'Strassenstr. 223'
    extended 'asdfadsf'
    city 'Zürich'
    sequence :primary_email { |n| "primary_#{n}@example.com" }
    sequence :primary_phone { |n| "+99 99 999 999#{n}" }
    postal_code '8047'
  end
end
