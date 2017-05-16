FactoryGirl.define do
  factory :contact do
    sequence :name { |n| "Test name #{n}" }
    street 'Strassenstr. 223'
    extended 'asdfadsf'
    city 'Zürich'
    postal_code '8047'
    contact_emails do |e|
      Array.new(3).map { |_n| e.association(:contact_email) }
    end
    contact_phones do |p|
      Array.new(3).map { |_n| p.association(:contact_phone) }
    end
  end
end
