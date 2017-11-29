FactoryBot.define do
  factory :email_template do
    kind 0
    sequence :subject do |n|
      "demo subject_#{n}"
    end
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    active true

    trait :fakered do
      subject { Faker::Hobbit.quote }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{Faker::HeyArnold.quote}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
    end

    trait :trial do
      kind { 1 }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{Faker::HeyArnold.quote}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject '%{Anrede} %{Name}'
    end

    trait :half_year do
      kind { 3 }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{Faker::HeyArnold.quote}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject '%{Anrede} %{Name}'
    end

    factory :email_template_seed, traits: [:fakered]
    factory :email_template_trial, traits: [:trial]
    factory :email_template_half_year, traits: [:half_year]
  end
end
