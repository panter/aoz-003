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
      subject { FFaker::Lorem.sentence }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
    end

    trait :trial do
      kind { 1 }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject '%{Anrede} %{Name}'
    end

    trait :half_year do
      kind { 3 }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject '%{Anrede} %{Name}'
    end

    trait :termination do
      kind { 2 }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n"
      end
      subject '%{Anrede} %{Name}'
    end

    factory :email_template_seed, traits: [:fakered]
    factory :email_template_trial, traits: [:trial]
    factory :email_template_half_year, traits: [:half_year]
    factory :email_template_termination, traits: [:termination]
  end
end
