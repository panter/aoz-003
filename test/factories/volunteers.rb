FactoryBot.define do
  factory :volunteer do
    birth_year { Faker::Date.birthday(18, 85) }
    contact
    salutation { ['mr', 'mrs'].sample }
    acceptance :accepted
    group_offer_categories { |category| [category.association(:group_offer_category)] }

    trait :with_language_skills do
      language_skills do |language_skill|
        Array.new(2) { language_skill.association(:language_skill) }
      end
    end

    trait :with_assignment do
      assignments do |assignment|
        [assignment.association(:assignment, period_start: 300.days.ago, period_end: 20.days.ago)]
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

    trait :female do
      salutation { 'mrs' }
    end

    trait :male do
      salutation { 'mr' }
    end

    trait :seed_contact do
      association :contact, factory: :contact_seed
    end

    trait :external do
      external true
    end

    trait :zuerich do
      association :contact, factory: :contact_zuerich
    end

    trait :faker_extra do
      profession { Faker::Company.profession }
      working_percent { "#{Faker::Number.between(1, 10)}0" }
    end

    trait :fake_single_assignments do
      man { [true, false].sample }
      woman { [true, false].sample }
      family { [true, false].sample }
      kid { [true, false].sample }
      unaccompanied { [true, false].sample }
    end

    trait :fake_availability do
      flexible { [true, false].sample }
      morning { [true, false].sample }
      afternoon { [true, false].sample }
      evening { [true, false].sample }
      workday { [true, false].sample }
      weekend { [true, false].sample }
    end

    factory :volunteer_with_user do
      after(:create) do |volunteer|
        volunteer.user = FactoryBot.create(:user_volunteer)
        volunteer.save
      end
    end
    factory :volunteer_external, traits: [:external]
    factory :volunteer_z, traits: [:zuerich]

    factory(
      :volunteer_seed,
      traits: [
        :seed_contact, :with_language_skills, :with_journals, :faker_extra,
        :fake_availability, :fake_single_assignments
      ]
    )
  end
end
