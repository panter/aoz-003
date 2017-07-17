FactoryGirl.define do
  factory :user do
    sequence :email { |n| "superadmin#{n}@example.com" }
    password 'asdfasdf'
    role 'superadmin'

    trait :with_clients do
      client_amt = 5
      clients do |client|
        1.step(client_amt).to_a.map { |n| client.association(:client) }
      end
    end

    trait :with_departments do
      department do
        Array.new(1).map { |_n| create(:department) }
      end
    end
    association :profile, strategy: :build
  end
end
