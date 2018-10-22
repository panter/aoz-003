FactoryBot.define do
  factory :volunteer do
    birth_year { FFaker::Time.between(18.years.ago, 85.years.ago) }
    contact
    salutation { ['mr', 'mrs'].sample }
    acceptance :accepted
    group_offer_categories { |category| [category.association(:group_offer_category)] }
    waive { false }
    iban { generate :iban }
    bank { 'Bank' }
    association :registrar, factory: :user

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

    trait :external do
      external { true }
      acceptance { :accepted }
    end

    trait :internal do
      external { false }
    end

    trait :zuerich do
      association :contact, factory: :contact_zuerich
    end

    trait :faker_extra do
      profession { FFaker::Job.title }
      working_percent { "#{rand(1..10)}0" }
    end

    trait :fake_single_assignments do
      man { [true, false].sample }
      woman { [true, false].sample }
      family { [true, false].sample }
      kid { [true, false].sample }
      teenager { [true, false].sample }
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

    trait :imported do
      acceptance :invited
      import
    end

    after(:build) do |volunteer|
      if volunteer.accepted? && volunteer.internal?
        volunteer.user_id = User.create(role: 'volunteer', email: volunteer.contact.primary_email).id
      end
      if volunteer.salutation == 'mrs'
        volunteer.contact.first_name = I18n.t('faker.name.female_first_name').sample
      elsif volunteer.salutation == 'mr'
        volunteer.contact.first_name = I18n.t('faker.name.male_first_name').sample
      end
    end

    factory :volunteer_with_user do
      after(:save) do |volunteer|
        unless volunteer.accepted? || volunteer.user.present?
          previous_acceptance = volunteer.acceptance
          volunteer.accepted!
          volunteer.update(acceptance: previous_acceptance)
        end
      end
    end

    factory :volunteer_external, traits: [:external]
    factory :volunteer_internal, traits: [:internal]
    factory :volunteer_z, traits: [:zuerich]

    factory(
      :volunteer_seed,
      traits: [
        :with_language_skills, :with_journals, :faker_extra,
        :fake_availability, :fake_single_assignments
      ]
    )
  end
end
