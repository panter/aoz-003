FactoryGirl.define do
  factory :client do
    association :user
    association :contact

    trait :zuerich do
      association :contact, factory: :contact_zuerich
    end

    trait :seed_contact do
      association :contact, factory: :contact_seed
    end

    trait :random_gender do
      salutation ['mr', 'mrs'].sample
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
      flexible [true, false].sample
      morning [true, false].sample
      afternoon [true, false].sample
      evening [true, false].sample
      workday [true, false].sample
      weekend [true, false].sample
    end

    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end

    trait :faker_misc do
      gender_request Client::GENDER_REQUESTS.sample
      age_request Client::AGE_REQUESTS.sample
      permit Client::PERMITS.sample
      goals Faker::Lorem.sentence
      education Faker::Company.profession
      interests Faker::Lorem.sentence
      comments Faker::Lorem.sentence
      other_request Faker::Lorem.sentence
      actual_activities Faker::Lorem.sentence
      detailed_description Faker::Lorem.sentence
      nationality ISO3166::Country.codes.sample
    end

    factory :client_z, traits: [:zuerich]
    factory(
      :client_seed,
      traits: [
        :seed_contact, :with_language_skills, :random_gender, :with_journals, :fake_availability,
        :faker_misc
      ]
    )
  end
end
