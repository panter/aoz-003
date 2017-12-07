FactoryBot.define do
  factory :user do
    email { "#{Time.zone.now.to_i}#{Faker::Internet.user_name}my-user@temporary-mail.com" }
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

    trait :with_department do
      department { [create(:department)] }
    end

    trait :without_profile do
      email { Faker::Internet.email("no_profile_user#{Time.zone.now.to_i}") }
      profile {}
    end

    trait :fake_email do

    end

    after(:create) do |user|
      next unless user.email.include?('my-user@temporary-mail.com')
      user.email = user.role + '_' + Faker::Internet.email(
        Faker::Internet.user_name(user.profile.contact.natural_name)
      )
      user.profile.contact.primary_email = user.email
      user.save
    end

    factory :social_worker, traits: [:social_worker]
    factory :department_manager, traits: [:department_manager, :with_department]
    factory :user_volunteer, traits: [:volunteer]
    factory :user_fake_email, traits: [:fake_email]
  end
end
