FactoryGirl.define do
  factory :user do
    sequence :email { |n| "superadmin#{n}@example.com" }
    password 'asdfasdf'
    role 'superadmin'

    trait :with_profile do
      contact do |c|
        c.association(:contact)
      end
    end

    trait :with_clients do
      client_amt = 5
      clients do |client|
        1.step(client_amt).to_a.map { |n| client.association(:client) }
      end
    end

    trait :with_departments do
      department do
        Array.new(3).map { |_n| create(:department) }
      end
    end
  end
end
