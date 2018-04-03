FactoryBot.define do
  factory :email_template do
    kind { EmailTemplate.kinds[:signup] }
    sequence :subject do |n|
      "demo subject_#{n}"
    end
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    active true

    trait :signup do
      subject '%{Anrede} %{Name}'
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}"
      end
    end

    trait :trial do
      kind { EmailTemplate.kinds[:trial] }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject '%{Anrede} %{Name}'
    end

    trait :half_year do
      kind { EmailTemplate.kinds[:half_year] }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject '%{Anrede} %{Name}'
    end

    trait :termination do
      kind { EmailTemplate.kinds[:termination] }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n"
      end
      subject '%{Anrede} %{Name}'
    end

    factory :email_template_signup, traits: [:signup]
    factory :email_template_trial, traits: [:trial]
    factory :email_template_half_year, traits: [:half_year]
    factory :email_template_termination, traits: [:termination]
  end
end
