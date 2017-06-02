FactoryGirl.define do
  factory :contact do
    sequence :first_name { |n| "first name #{n}" }
    sequence :last_name { |n| "last name #{n}" }
    street 'Strassenstr. 223'
    extended 'asdfadsf'
    city 'Zürich'
    postal_code '8047'
    contact_emails do |e|
      Array.new(3).map { e.association(:contact_email) }
    end
    contact_phones do |p|
      Array.new(3).map { p.association(:contact_phone) }
    end
  end
end
