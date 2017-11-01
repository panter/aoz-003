include ApplicationHelper
Faker::Config.locale = 'de'

EMAIL_DOMAIN = '@example.com'.freeze

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
  user = FactoryBot.create(:user, role: role, email: "#{role}#{EMAIL_DOMAIN}",
    password: 'asdfasdf')
  user.profile.contact.primary_email = "#{role}#{EMAIL_DOMAIN}"
  user.save!
end

FactoryBot.create(
  :user_volunteer,
  password: 'asdfasdf',
  email: "volunteer#{EMAIL_DOMAIN}",
  volunteer: FactoryBot.create(:volunteer)
)

User.where(role: ['superadmin', 'social_worker']).each do |user|
  next if user.clients.count > 1

  journals = [
    Journal.new(
      body: Faker::Lorem.sentence(rand(2..5)),
      user: user,
      category: random_category
    ),
    Journal.new(
      body: Faker::Lorem.sentence(rand(2..5)),
      user: user,
      category: random_category
    )
  ]
  user.clients << Array.new(2).map do
    FactoryBot.create :client_seed, journals: journals, relatives: make_relatives
  end
  user.save
end

def create_two_group_offers(group_offer_category)
  [
    FactoryBot.create(:group_offer, necessary_volunteers: 2,
      group_offer_category: group_offer_category, creator: User.find_by(role: 'department_manager'),
      volunteers: [FactoryBot.create(:volunteer_seed), FactoryBot.create(:volunteer_seed)]),
    FactoryBot.create(:group_offer, necessary_volunteers: 2, creator: User.find_by(role: 'superadmin'),
      group_offer_category: group_offer_category,
      volunteers: [FactoryBot.create(:volunteer_seed), FactoryBot.create(:volunteer_seed)])
  ]
end

if Department.count < 1
  group_offer_category = FactoryBot.create :group_offer_category
  # first department for user with login
  department_manager = User.find_by role: 'department_manager'
  department = FactoryBot.create :department, user: [department_manager]
  department.update(group_offers: create_two_group_offers(group_offer_category))
  # additional departments
  3.times do
    department = FactoryBot.create :department, user: [FactoryBot.create(:department_manager)]
    department.update(group_offers: create_two_group_offers(group_offer_category))
  end
end

# Create volunteers for each acceptance type
Volunteer.acceptance_collection.each do |acceptance|
  vol = FactoryBot.create(:volunteer_seed, acceptance: acceptance)
  # Create a volunteer user for the volunteer if accepted
  if vol.accepted?
    FactoryBot.create(:user, role: 'volunteer', volunteer: vol, email: vol.contact.primary_email)
  end
end

# Create VolunteerEmails
if VolunteerEmail.count < 1
  FactoryBot.create :volunteer_email_seed, active: true
  2.times do
    FactoryBot.create :volunteer_email_seed, active: false
  end
end

# Create assignments
if Assignment.count < 1
  10.times do
    client = FactoryBot.create :client, state: Client::ACTIVE
    volunteer = FactoryBot.create :volunteer
    assignment = FactoryBot.create(:assignment, volunteer: volunteer, client: client,
      creator_id: User.find_by(role: 'superadmin').id, period_start: 5.days.ago.to_date)
    assignment.hours << Array.new(4).map do
      FactoryBot.create(:hour, volunteer: volunteer,
        meeting_date: Faker::Date.between(assignment.period_start + 1, 2.days.ago))
    end
  end
end

# create Assignment Journal
Assignment.all.each do |assignment|
  FactoryBot.create(:feedback, volunteer: assignment.volunteer, feedbackable: assignment,
    author_id: [User.superadmins.last.id, assignment.volunteer&.user&.id].compact.sample)
end
