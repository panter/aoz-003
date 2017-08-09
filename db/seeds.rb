
Faker::Config.locale = 'de'

def random_relation
  [
    'wife', 'husband', 'mother', 'father', 'daughter',
    'son', 'sister', 'brother', 'aunt', 'uncle'
  ].sample
end

def random_age_request
  Client::AGE_REQUESTS.sample
end

def random_gender_request
  Client::GENDER_REQUESTS.sample
end

def random_category
  Journal::CATEGORIES.sample
end

def make_relatives
  Array.new(2).map do
    Relative.new do |relative|
      relative.first_name = Faker::Name.first_name
      relative.last_name = Faker::Name.last_name
      relative.relation = random_relation
      relative.birth_year = Faker::Date.birthday(18, 65)
    end
  end
end

def make_lang_skills
  Array.new(3).map do
    LanguageSkill.new do |l|
      l.language = I18nData.languages.to_a.sample[0]
      l.level = LanguageSkill::LANGUAGE_LEVELS.sample
    end
  end
end

User.role_collection.each do |role|
  User.find_or_create_by(email: "#{role}@example.com") do |user|
    user.password = 'asdfasdf'
    user.role = role
    user.profile = Profile.new do |profile|
      profile.build_contact(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        postal_code: Faker::Address.zip_code,
        city: Faker::Address.city,
        street: Faker::Address.street_address,
        primary_email: Faker::Internet.email,
        primary_phone: Faker::PhoneNumber.phone_number
      )
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
        last_name: Faker::Name.last_name,
        primary_email: Faker::Internet.email,
        primary_phone: Faker::PhoneNumber.phone_number,
        street: Faker::Address.street_address,
        postal_code: Faker::Address.zip_code,
        city: Faker::Address.city
      )
      client.journals = [
        Journal.new(
          subject: Faker::Lorem.sentence(rand(2..5)),
          body: Faker::Lorem.sentence(rand(2..5)),
          user: user,
          category: random_category
        ),
        Journal.new(
          subject: Faker::Lorem.sentence(rand(2..5)),
          body: Faker::Lorem.sentence(rand(2..5)),
          user: user,
          category: random_category
        )
      ]
      client.birth_year = Faker::Date.birthday(18, 65)
      client.salutation = ['mr', 'mrs'].sample
      client.nationality = ISO3166::Country.codes.sample
      client.relatives = make_relatives
      client.language_skills = make_lang_skills
      client.age_request = random_age_request
      client.gender_request = random_gender_request
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
      c.primary_email = Faker::Internet.email
      c.primary_phone = Faker::PhoneNumber.phone_number
    end
    d.user.push User.find_by(role: 'department_manager')
  end
  department.save!
end

Volunteer.state_collection.each do |state|
  vol = Volunteer.new do |volunteer|
    volunteer.state = state.to_s
    volunteer.build_contact(
      title: Faker::Name.title,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      postal_code: Faker::Address.zip_code,
      city: Faker::Address.city,
      street: Faker::Address.street_address,
      primary_email: Faker::Internet.email,
      primary_phone: Faker::PhoneNumber.phone_number
    )
    volunteer.journals = [
      Journal.new(
        subject: Faker::Lorem.sentence(rand(2..5)),
        body: Faker::Lorem.sentence(rand(2..5)),
        user: User.first,
        category: random_category
      ),
      Journal.new(
        subject: Faker::Lorem.sentence(rand(2..5)),
        body: Faker::Lorem.sentence(rand(2..5)),
        user: User.first,
        category: random_category
      )
    ]
    volunteer.birth_year = Faker::Date.birthday(18, 75)
    volunteer.profession = Faker::Company.profession
    volunteer.salutation = ['mr', 'mrs'].sample
    volunteer.working_percent = "#{rand(2..10)}0"
    Volunteer::SINGLE_ACCOMPANIMENTS.each do |bool_attr|
      volunteer[bool_attr] = [true, false].sample
    end
    Volunteer::GROUP_ACCOMPANIMENTS.each do |bool_attr|
      volunteer[bool_attr] = [true, false].sample
    end
    [:nationality, :additional_nationality].each { |n| volunteer[n] = ISO3166::Country.codes.sample }
    volunteer.education = "#{Faker::Educator.secondary_school}, #{Faker::Educator.university}"
    [:motivation, :expectations, :strengths, :interests].each do |attribute|
      volunteer[attribute] = Faker::Lorem.sentence(rand(2..5))
    end
    volunteer.strengths = "#{Faker::Job.key_skill}, #{Faker::Job.key_skill}, #{Faker::Job.key_skill}"
    volunteer.language_skills = make_lang_skills
  end
  vol.save!
end

if VolunteerEmail.count < 1
  5.times do
    VolunteerEmail.new do |ve|
      ve.subject = Faker::Lorem.sentence
      ve.title = Faker::Lorem.sentence
      ve.body = Array.new(5).map do
        Faker::ChuckNorris.fact
      end.join(' ')
      ve.active = true
      ve.user = User.first
    end.save
  end
end

Schedule.all.each do |s|
  s.available = [true, false].sample
  s.save!
end
