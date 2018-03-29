FactoryBot.define do
  factory :contact do
    first_name { FFaker::Name.unique.first_name }
    last_name { FFaker::Name.unique.first_name }
    extended { FFaker::Address.secondary_address }
    street { FFaker::Address.street_address }
    city { FFaker::Address.city }
    postal_code { rand(1100..7500).to_s }
    sequence :primary_email do |n|
      "primary_#{n}@example.com"
    end
    primary_phone { FFaker::PhoneNumberCH.home_work_phone_number }
    secondary_phone { FFaker::PhoneNumberCH.mobile_phone_number }

    trait :faker_name do
      first_name { FFaker::Name.unique.first_name }
      last_name { FFaker::Name.unique.last_name }
    end

    trait :female_name do
      first_name { I18n.t('faker.name.female_first_name').sample }
      last_name { FFaker::Name.unique.last_name }
    end

    trait :male_name do
      first_name { I18n.t('faker.name.male_first_name').sample }
      last_name { FFaker::Name.unique.last_name }
    end

    trait :faker_email do
      primary_email { FFaker::Internet.unique.email }
    end

    trait :zuerich do
      city 'Zürich'
      postal_code { Client.zuerich_zips.sample }
    end

    trait :department do
      sequence :last_name do |n|
        "Department_number#{n}"
      end
    end

    factory :contact_department, traits: [:zuerich, :department]
    factory :contact_zuerich, traits: [:zuerich]
    factory :contact_seed, traits: [:faker_name, :faker_email]
  end
end
