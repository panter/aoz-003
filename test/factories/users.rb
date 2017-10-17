FactoryGirl.define do
  factory :user do
    sequence :email { |n| "superadmin#{n}@example.com" }
    password 'asdfasdf'
    role User::SUPERADMIN

    association :profile, strategy: :build

    trait :social_worker do
      role User::SOCIAL_WORKER
    end

    trait :volunteer do
      role User::VOLUNTEER
    end

    trait :department_manager do
      role User::DEPARTMENT_MANAGER
    end

    trait :with_clients do
      client_amt = 5
      clients do |client|
        1.step(client_amt).to_a.map { client.association(:client) }
      end
    end

    trait :with_departments do
      department do
        Array.new(1).map { create(:department) }
      end
    end

    trait :without_profile do
      profile {}
    end

    factory :social_worker, traits: [:social_worker]
    factory :department_manager, traits: [:department_manager, :with_departments]
    factory :user_volunteer, traits: [:volunteer]
  end
end
