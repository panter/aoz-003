
Faker::Config.locale = 'de'

def random_relation
  [
    'brother', 'sister', 'mother', 'father', 'foster-mother',
    'foster-father', 'friend', 'neighbour', 'cousin', 'uncle', 'aunt',
    'son', 'doughter', 'newphew', 'niece'
  ].sample
end

def make_person_data(subject)
  subject.first_name = Faker::Name.first_name
  subject.last_name = Faker::Name.last_name
  subject.date_of_birth = Faker::Date.birthday(18, 75)
  subject.zip = Faker::Address.zip_code
  subject.city = Faker::Address.city
  subject.street = Faker::Address.street_address
  subject.email = Faker::Internet.email
  subject.phone = Faker::PhoneNumber.phone_number
  subject.gender = ['male', 'female'].sample
end

def make_relatives
  Array.new(2).map do
    Relative.new do |relative|
      relative.first_name = Faker::Name.first_name
      relative.last_name = Faker::Name.last_name
      relative.relation = random_relation
      relative.date_of_birth = Faker::Date.birthday(18, 65)
    end
  end
end

def make_lang_skills
  Array.new(3).map do
    LanguageSkill.new do |l|
      l.language = I18nData.languages.to_a.sample[0]
      l.level = LanguageSkill.language_level_collection.sample
    end
  end
end

def make_schedule
  Schedule.build.each do |day|
    day.each do |time|
      time.available = [true, false].sample
    end
  end
end

User.role_collection.each do |role|
  User.find_or_create_by!(email: "#{role}@example.com") do |user|
    user.password = 'asdfasdf'
    user.role = role
    user.profile = Profile.new do |profile|
      profile.first_name = Faker::Name.first_name
      profile.last_name = Faker::Name.last_name
      profile.phone = Faker::PhoneNumber.phone_number
      profile.address = Faker::Address.street_address
      profile.profession = Faker::Company.profession
      [:monday, :tuesday, :wednesday, :thursday, :friday].each do |day|
        profile[day] = [true, false].sample
      end
    end
  end
end

User.where(role: ['superadmin', 'social_worker']).each do |user|
  next if user.clients.count > 1
  user.clients = Array.new(4).map do
    Client.new do |client|
      client.build_contact(
       first_name: Faker::Name.first_name,
       last_name: Faker::Name.last_name
      )

      client.contact.contact_emails.build(
        body: Faker::Internet.unique.email
      )

      client.date_of_birth = Faker::Date.birthday(18, 65)
      client.gender = ['male', 'female'].sample
      client.nationality = ISO3166::Country.codes.sample
      client.relatives = make_relatives
      client.language_skills = make_lang_skills
      client.schedules << make_schedule
    end
  end
  user.save
end

if Department.count < 1
  department = Department.new do |d|
    d.contact = Contact.new do |c|
      c.last_name = 'Bogus Department'
      c.street = Faker::Address.street_address
      c.postal_code = Faker::Address.zip_code
      c.city = Faker::Address.city
      c.contact_emails = Array.new(3).map do
        ContactEmail.new do |email|
          email.body = Faker::Internet.email
          email.label = ContactEmail.label_collection.sample
        end
      end
      c.contact_phones = Array.new(3).map do
        ContactPhone.new do |phone|
          phone.body = Faker::PhoneNumber.phone_number
          phone.label = ContactPhone.label_collection.sample
        end
      end
    end
    d.user.push User.find_by(role: 'department_manager')
  end
  department.save!
end

Volunteer.state_collection_for_reviewed.each do |state|
  Volunteer.new do |volunteer|
    volunteer.build_contact(
     first_name: Faker::Name.first_name,
     last_name: Faker::Name.last_name,
     postal_code: Faker::Address.zip_code,
     city: Faker::Address.city,
     street: Faker::Address.street_address
    )
    volunteer.contact.contact_emails.build(
      body: Faker::Internet.unique.email
    )
    volunteer.contact.contact_phones.build(
      body: Faker::PhoneNumber.phone_number
    )
    volunteer.date_of_birth = Faker::Date.birthday(18, 75)
    volunteer.profession = Faker::Company.profession
    volunteer.gender = ['male', 'female'].sample
    [:experience, :man, :woman, :family, :kid, :sport, :creative, :music,
     :culture, :training, :german_course, :adults, :teenagers, :children].each do |bool_attr|
      volunteer[bool_attr] = [true, false].sample
    end
    [:nationality, :additional_nationality].each { |n| volunteer[n] = ISO3166::Country.codes.sample }
    volunteer.education = "#{Faker::Educator.secondary_school}, #{Faker::Educator.university}"
    [:motivation, :expectations, :strengths, :interests].each do |attribute|
      volunteer[attribute] = Faker::Lorem.sentence(rand(2..5))
    end
    volunteer.skills = "#{Faker::Job.key_skill}, #{Faker::Job.key_skill}, #{Faker::Job.key_skill}"
    volunteer.duration = ['long', 'short'].sample
    volunteer.region = ['city', 'region', 'canton'].sample
    volunteer.language_skills = make_lang_skills
    volunteer.schedules << make_schedule
  end
end
