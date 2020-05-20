FactoryBot.define do
  factory :client do
    user
    contact
    salutation { ['mr', 'mrs'].sample }

    trait :zuerich do
      association :contact, factory: :contact_zuerich
    end

    trait :with_relatives do
      relatives do |relative|
        Array.new(2) { relative.association(:relative) }
      end
    end

    trait :with_journals do
      journals do |journal|
        [
          journal.association(:journal_seed),
          journal.association(:journal_seed),
          journal.association(:journal_seed)
        ]
      end
    end

    trait :fake_availability do
      flexible { [true, false].sample }
      morning { [true, false].sample }
      afternoon { [true, false].sample }
      evening { [true, false].sample }
      workday { [true, false].sample }
      weekend { [true, false].sample }
    end

    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end

    trait :faker_common do
      goals { FFaker::Lorem.sentence }
      education { FFaker::Education.major }
      interests { FFaker::Lorem.sentence }
      comments { FFaker::Lorem.sentence }
      other_request { FFaker::Lorem.sentence }
      actual_activities { FFaker::Lorem.sentence }
      detailed_description { FFaker::Lorem.sentence }
      nationality { ISO3166::Country.codes.sample }
    end

    trait :faker_misc do
      gender_request { Client::GENDER_REQUESTS.sample }
      age_request { Client::AGE_REQUESTS.sample }
      permit { Client::PERMITS.sample }
      goals { FFaker::Lorem.sentence }
      education { FFaker::Education.major }
      interests { FFaker::Lorem.sentence }
      comments { FFaker::Lorem.sentence }
      other_request { FFaker::Lorem.sentence }
      actual_activities { FFaker::Lorem.sentence }
      detailed_description { FFaker::Lorem.sentence }
      nationality { ISO3166::Country.codes.sample }
    end

    after(:build) do |client|
      if client.salutation == 'mrs'
        client.contact.first_name = I18n.t('faker.name.female_first_name').sample
      elsif client.salutation == 'mr'
        client.contact.first_name = I18n.t('faker.name.male_first_name').sample
      end
    end

    factory :client_common, traits: [:faker_common, :with_language_skills, :fake_availability, :with_relatives, :zuerich]
    factory :client_z, traits: [:zuerich]
    factory(
      :client_seed,
      traits: [
        :with_language_skills, :with_journals, :fake_availability,
        :faker_misc
      ]
    )
  end
end
