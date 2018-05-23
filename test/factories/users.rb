FactoryBot.define do
  factory :user do
    email { FFaker::Internet.unique.email }
    password 'asdfasdf'
    role User::SUPERADMIN

    association :profile, strategy: :build

    after :build do |user|
      user.profile&.user = user
    end

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

    trait :with_department do
      department { [create(:department)] }
    end

    trait :without_profile do
      email { FFaker::Internet.unique.email("no_profile_user#{Time.zone.now.to_i}") }
      profile {}
    end

    factory :social_worker, traits: [:social_worker]
    factory :department_manager, traits: [:department_manager, :with_department]
    factory :department_manager_without_department, traits: [:department_manager]
    factory :user_volunteer, traits: [:volunteer]
  end
end
