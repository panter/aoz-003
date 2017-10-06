include ApplicationHelper
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

[:superadmin, :social_worker, :department_manager].each do |role|
  user = FactoryGirl.create(:user, role: role, email: "#{role}@example.com", password: 'asdfasdf')
  user.profile.contact.primary_email = "#{role}@example.com"
  user.save!
end

FactoryGirl.create(:user_volunteer, volunteer: FactoryGirl.create(:volunteer),
  email: 'volunteer@example.com', password: 'asdfasdf')


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
      availability_collection.each do |availability|
        client[availability] = [true, false].sample
      end
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

Volunteer.acceptance_collection.each do |state|
  vol = Volunteer.new do |volunteer|
    volunteer.acceptance = state
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
    volunteer.experience = [true, false].sample
    volunteer.zurich = [true, false].sample
    volunteer.strengths = "#{Faker::Job.key_skill}, #{Faker::Job.key_skill}"
    volunteer.language_skills = make_lang_skills
    availability_collection.each do |availability|
      volunteer[availability] = [true, false].sample
    end
  end
  vol.save!
  if vol.accepted?
    FactoryGirl.create(:user, role: 'volunteer', volunteer: vol, email: vol.contact.primary_email)
  end
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

if Assignment.count < 1
  10.times do
    client = FactoryGirl.create :client, state: Client::ACTIVE
    volunteer = FactoryGirl.create :volunteer
    assignment = FactoryGirl.create(:assignment, volunteer: volunteer, client: client,
      creator_id: User.find_by(role: 'superadmin').id, period_start: 5.days.ago.to_date)
    assignment.hours << Array.new(4).map do
      FactoryGirl.create(:hour, volunteer: volunteer,
        meeting_date: Faker::Date.between(assignment.period_start + 1, 2.days.ago))
    end
  end
end

Assignment.all.each do |assignment|
  FactoryGirl.create(:assignment_journal, volunteer: assignment.volunteer, assignment: assignment,
    author_id: [User.superadmins.last.id, assignment.volunteer&.user&.id].compact.sample)
end
