FactoryBot.define do
  factory :contact do
    first_name { FFaker::Name.unique.first_name }
    last_name { FFaker::Name.unique.last_name }
    extended { FFaker::Address.secondary_address }
    street { FFaker::Address.street_address }
    city { FFaker::Address.city }
    postal_code { rand(1100..7500).to_s }
    primary_email { "test_email_#{Time.zone.now.to_f}@example.com" }
    primary_phone { FFaker::PhoneNumberCH.home_work_phone_number }
    secondary_phone { FFaker::PhoneNumberCH.mobile_phone_number }

    trait :female_name do
      first_name { I18n.t('faker.name.female_first_name').sample }
      last_name { FFaker::Name.unique.last_name }
    end

    trait :male_name do
      first_name { I18n.t('faker.name.male_first_name').sample }
      last_name { FFaker::Name.unique.last_name }
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

    trait :time_email do
      primary_email { "test_mail#{Time.zone.now.to_f}@example.com" }
    end

    factory :contact_test_mail, traits: [:time_email]
    factory :contact_department, traits: [:zuerich, :department]
    factory :contact_zuerich, traits: [:zuerich]
  end
end
