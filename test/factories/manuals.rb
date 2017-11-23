FactoryBot.define do
  factory :manual do
    category { Manual::CATEGORIES.sample }
    sequence :title do |n|
      "demo title_#{n}"
    end
    sequence :description do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    user
    attachment_file_name { Faker::File.mime_type }

    trait :fakered do
      title { Faker::Hobbit.quote }
      description { Faker::HeyArnold.quote }
    end

    factory :manual_seed, traits: [:fakered]
  end
end
