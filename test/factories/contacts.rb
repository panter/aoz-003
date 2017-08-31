FactoryGirl.define do
  factory :contact do
    sequence :first_name { |n| "first name #{n}" }
    sequence :last_name { |n| "last name #{n}" }
    extended Faker::Address.secondary_address
    street Faker::Address.street_address
    city Faker::Address.city
    postal_code Faker::Number.between(1100, 7500).to_s
    sequence :primary_email { |n| "primary_#{n}@example.com" }
    primary_phone Faker::PhoneNumber.phone_number
    secondary_phone Faker::PhoneNumber.cell_phone

    trait :zuerich do
      city 'Zürich'
      postal_code Client.zuerich_zips.sample
    end

    trait :department do
      sequence :last_name { |n| "Department_number#{n}" }
    end

    factory :contact_department, traits: [:zuerich, :department]
    factory :contact_zuerich, traits: [:zuerich]
  end
end
