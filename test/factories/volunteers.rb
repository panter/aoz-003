FactoryGirl.define do
  factory :volunteer do
    birth_year Faker::Date.birthday(18, 85)
    contact
    salutation 'mrs'
    acceptance :accepted

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

    trait :seed_contact do
      association :contact, factory: :contact_seed
    end

    trait :random_gender do
      salutation ['mr', 'mrs'].sample
    end

    trait :external do
      external true
    end

    trait :zuerich do
      association :contact, factory: :contact_zuerich
    end

    trait :faker_extra do
      profession Faker::Company.profession
      working_percent "#{Faker::Number.between(1, 10)}0"
    end

    trait :fake_single_assignments do
      man [true, false].sample
      woman [true, false].sample
      family [true, false].sample
      kid [true, false].sample
      unaccompanied [true, false].sample
    end

    trait :fake_group_assignments do
      sport [true, false].sample
      creative [true, false].sample
      music [true, false].sample
      culture [true, false].sample
      training [true, false].sample
      german_course [true, false].sample
      dancing [true, false].sample
      health [true, false].sample
      cooking [true, false].sample
      excursions [true, false].sample
      women [true, false].sample
      teenagers [true, false].sample
      children [true, false].sample
      other_offer [true, false].sample
    end

    trait :fake_availability do
      flexible [true, false].sample
      morning [true, false].sample
      afternoon [true, false].sample
      evening [true, false].sample
      workday [true, false].sample
      weekend [true, false].sample
    end

    factory :volunteer_external, traits: [:external]
    factory :volunteer_z, traits: [:zuerich]

    factory(
      :volunteer_seed,
      traits: [
        :seed_contact, :with_language_skills, :random_gender, :with_journals, :faker_extra,
        :fake_availability, :fake_single_assignments, :fake_group_assignments
      ]
    )
  end
end
