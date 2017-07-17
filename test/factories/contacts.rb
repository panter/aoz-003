FactoryGirl.define do
  factory :contact do
    sequence :first_name { |n| "first name #{n}" }
    sequence :last_name { |n| "last name #{n}" }
    street 'Strassenstr. 223'
    extended 'asdfadsf'
    city 'Zürich'
    sequence :primary_email { |n| "primary_#{n}@example.com" }
    sequence :primary_phone { |n| "+99 99 999 999#{n}" }
    postal_code '8047'

    contact_emails do |e|
      Array.new(2).map { e.association(:contact_email) }
    end

    contact_phones do |p|
      Array.new(2).map { p.association(:contact_phone) }
    end
  end
end
