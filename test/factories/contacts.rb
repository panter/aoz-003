FactoryBot.define do
  factory :contact do
    sequence :first_name { Faker::Name.first_name }
    sequence :last_name { Faker::Name.first_name }
    extended { Faker::Address.secondary_address }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    postal_code { Faker::Number.between(1100, 7500).to_s }
    sequence :primary_email { |n| "primary_#{n}@example.com" }
    primary_phone { Faker::PhoneNumber.phone_number }
    secondary_phone { Faker::PhoneNumber.cell_phone }

    trait :faker_name do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :faker_email do
      primary_email { Faker::Internet.email }
    end

    trait :zuerich do
      city 'Zürich'
      postal_code { Client.zuerich_zips.sample }
    end

    trait :department do
      sequence :last_name { |n| "Department_number#{n}" }
    end

    factory :contact_department, traits: [:zuerich, :department]
    factory :contact_zuerich, traits: [:zuerich]
    factory :contact_seed, traits: [:faker_name, :faker_email]
  end
end
