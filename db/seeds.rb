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

User.role_collection.each do |role|
  new_user = User.find_or_create_by(email: "#{role}@example.com") do |new_user|
    new_user.password = 'asdfasdf'
    new_user.role = role
  end
  new_user.profile = Profile.new do |profile|
    profile.build_contact(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      postal_code: Faker::Address.zip_code,
      city: Faker::Address.city,
      street: Faker::Address.street_address,
      primary_email: Faker::Internet.email,
      primary_phone: Faker::PhoneNumber.phone_number
    )
    profile.user_id = new_user.id
    profile.profession = Faker::Company.profession
    availability_collection.each do |availability|
      profile[availability] = [true, false].sample
    end
  end
  new_user.save!
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

Volunteer.acceptance_collection.each do |acceptance|
  15.times do
    volunteer = FactoryGirl.create(:volunteer, :with_language_skills, acceptance: acceptance)
    volunteer.contact.primary_email = Faker::Internet.safe_email(
      Faker::Internet.user_name(volunteer.full_name, %w(. _ -))
    )
    volunteer.save
    next if acceptance != :accepted
    next if [true, false].sample
    assignment_client = FactoryGirl.create(:client, user: User.superadmins.last)
    assignment = [
      FactoryGirl.build(:assignment, volunteer: volunteer, client: assignment_client,
        creator: User.superadmins.last, period_start: 300.days.ago, period_end: nil),
      FactoryGirl.build(:assignment, volunteer: volunteer, client: assignment_client,
        creator: User.superadmins.last, period_start: 300.days.ago, period_end: 100.days.ago),
      FactoryGirl.build(:assignment, volunteer: volunteer, client: assignment_client,
        creator: User.superadmins.last, period_start: 300.days.ago,
        period_end: Time.zone.now.to_date + 100)
    ].sample
    assignment.save
    volunteer.assignments = [assignment]
    volunteer.save!
    if acceptance == :accepted
      FactoryGirl.create(:user, role: 'volunteer', volunteer: volunteer,
        email: volunteer.contact.primary_email)
    end
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
    volunteer = FactoryGirl.create :volunteer, acceptance: :accepted, take_more_assignments: true
    assignment = FactoryGirl.create(:assignment, volunteer: volunteer, client: client,
      creator_id: User.find_by(role: 'superadmin').id)
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
