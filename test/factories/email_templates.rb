FactoryBot.define do
  factory :email_template do
    kind { :half_year_process_email }
    sequence :subject do |n|
      "demo subject_#{n}"
    end
    sequence :body do |n|
      "the demonstration rar ra ra body_#{n}"
    end
    active { true }

    trait :signup do
      subject { 'Vielen Dank für Ihre Anmeldung' }
      body do
        "Guten Tag\r\n\r\nVielen Dank für Ihr Interesse an einem Freiwilligeneinsatz " \
        'bei der AOZ. Wir werden Sie demnächst kontaktieren, um Sie für ein Erstgespr' \
        "äch zu uns einzuladen.\r\n\r\nFreundliche Grüsse\r\n\r\nDas Team der AOZ Fach"\
        'stelle Freiwilligenarbeit'
      end
      kind { :signup }
    end

    trait :half_year_process_email do
      kind { :half_year_process_email }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n%{Einsatz} %{EinsatzStart} "\
          '%{FeedbackLink}'
      end
      subject { '%{Anrede} %{Name}' }
    end

    trait :termination do
      kind { :termination }
      body do
        "%{Anrede} %{Name}\r\n\r\n#{FFaker::Lorem.paragraph}\r\n\r\n"
      end
      subject { '%{Anrede} %{Name}' }
    end

    factory :email_template_signup, traits: [:signup]
    factory :email_template_half_year_process_email, traits: [:half_year_process_email]
    factory :email_template_termination, traits: [:termination]
  end
end
