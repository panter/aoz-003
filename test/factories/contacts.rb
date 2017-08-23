FactoryGirl.define do
  factory :contact do
    sequence :first_name { |n| "first name #{n}" }
    sequence :last_name { |n| "last name #{n}" }
    extended 'asdfadsf'
    street 'Strassenstr. 223'
    city 'Rüdisüligen'
    postal_code (3000..3999).to_a.sample.to_s
    sequence :primary_email { |n| "primary_#{n}@example.com" }
    sequence :primary_phone { |n| "+99 99 999 999#{n}" }

    trait :zuerich do
      city 'Zürich'
      postal_code Client::ZURICH_ZIPS.sample
    end
  end
end
