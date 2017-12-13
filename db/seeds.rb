
include ApplicationHelper

Faker::Config.locale = 'de'
EMAIL_DOMAIN = '@example.com'.freeze

def puts_model_counts(lead, *models)
  puts "#{"\r\n" * 2}#{lead}\r\n#{'=' * 80}\r\n"
  models.each do |model|
    puts '%5o %s' % [model.count, model.to_s.pluralize]
  end
end

def random_relation
  ['wife', 'husband', 'mother', 'father', 'daughter', 'son', 'sister', 'brother', 'aunt',
   'uncle'].sample
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

FactoryBot.create(:department_manager, email: "department_manager#{EMAIL_DOMAIN}",
    password: 'asdfasdf')
FactoryBot.create(:volunteer_with_user)
          .user.update(password: 'asdfasdf', email: "volunteer#{EMAIL_DOMAIN}")
puts_model_counts('First Users created', User, Profile, Contact, Volunteer, Client, Department)

superadmin_and_social_worker = [:superadmin, :social_worker].map do |role|
  FactoryBot.create(:user, role: role, email: "#{role}#{EMAIL_DOMAIN}",
    password: 'asdfasdf')
end
puts_model_counts('Superadmin and SocialWorker created', User, Volunteer, Department, Client,
  Volunteer)

superadmin_and_social_worker.each do |user|
  next if user.clients.count > 1
  journals = [
    Journal.new(
      body: Faker::Lorem.sentence(rand(2..5)),
      user: user,
      category: Journal::CATEGORIES.sample
    )
  ]
  user.clients << Array.new(2).map do
    FactoryBot.create :client_seed, journals: journals, relatives: make_relatives, user: user
  end
  user.save
end
puts_model_counts('Journal created', User, Volunteer, Client, Journal, Relative)

def create_two_group_offers(group_offer_category)
  department_manager = User.find_by(role: 'department_manager')
  department = FactoryBot.create(:department, users: [department_manager])
  [
    FactoryBot.create(:group_offer, necessary_volunteers: 2,
      department: department,
      group_offer_category: group_offer_category, creator: department_manager),
    FactoryBot.create(:group_offer, necessary_volunteers: 2,
      group_offer_category: group_offer_category,
      department: department,
      creator: User.find_by(role: 'superadmin'))
  ]
  puts_model_counts('GroupOffers created', User, Volunteer, Department, Client, Volunteer,
    GroupOffer, GroupAssignment)
end

# Create volunteers for each acceptance type
Volunteer.acceptance_collection.each do |acceptance|
  if ['undecided', 'rejected'].include?(acceptance)
    FactoryBot.create(:volunteer_seed, acceptance: acceptance, user_id: nil)
  else
    FactoryBot.create(:volunteer_seed_with_user, acceptance: acceptance)
  end
end
puts_model_counts('After Volunteer created', User, Volunteer, Client)

# Create EmailTemplates
if EmailTemplate.count < 1
  FactoryBot.create :email_template_seed, active: true
  2.times do
    FactoryBot.create :email_template_seed, active: false
  end
  FactoryBot.create :email_template_trial, active: true
  2.times do
    FactoryBot.create :email_template_trial, active: false
  end
  FactoryBot.create :email_template_half_year, active: true
  2.times do
    FactoryBot.create :email_template_half_year, active: false
  end
end
puts_model_counts('After EmailTemplates created', User, EmailTemplate)

# Create assignments
if Assignment.count < 1
  # probezeit assignments
  Array.new(3).map { FactoryBot.create(:volunteer_seed_with_user) }
       .each do |volunteer|
    FactoryBot.create(
      :assignment,
      volunteer: volunteer,
      client: FactoryBot.create(:client, state: Client::ACTIVE, user: User.superadmins.first),
      creator: User.superadmins.first,
      period_start: Faker::Date.between(6.weeks.ago, 8.weeks.ago),
      period_end: nil
    )
  end
  # half_year assignments
  Array.new(3).map { FactoryBot.create(:volunteer_seed_with_user) }
       .each do |volunteer|
    assignment = FactoryBot.create(
      :assignment,
      volunteer: volunteer,
      client: FactoryBot.create(:client, state: Client::ACTIVE, user: User.superadmins.first),
      creator: User.superadmins.first,
      period_start: Faker::Date.between(6.months.ago, 12.months.ago),
      period_end: nil
    )
    FactoryBot.create(:hour, volunteer: volunteer, hourable: assignment,
      meeting_date: Faker::Date.between(assignment.period_start + 1, 2.days.ago))
    FactoryBot.create(:feedback, volunteer: volunteer, feedbackable: assignment,
      author: volunteer.user)
    FactoryBot.create(:trial_feedback, volunteer: volunteer, author: volunteer.user,
      trial_feedbackable: assignment)
  end
end
puts_model_counts('After Assignment created', User, Volunteer, Feedback, Hour, Assignment, Client, Feedback)

Array.new(2).map { FactoryBot.create(:group_offer, department: Department.all.sample) }
     .each do |group_offer|
  volunteers = Array.new(2).map { FactoryBot.create(:volunteer_seed_with_user) }

  group_assignment = GroupAssignment.create(volunteer: volunteers.first, group_offer: group_offer,
    period_start: Faker::Date.between(6.weeks.ago, 8.weeks.ago), period_end: nil)
  FactoryBot.create(:hour, volunteer: volunteers.first, hourable: group_assignment.group_offer,
    meeting_date: Faker::Date.between(group_assignment.period_start + 1, 2.days.ago))
  FactoryBot.create(:feedback, volunteer: volunteers.first, feedbackable: group_assignment,
    author_id: volunteers.first.user.id)

  group_assignment = GroupAssignment.create(volunteer: volunteers.last, group_offer: group_offer,
    period_start: Faker::Date.between(6.months.ago, 12.months.ago), period_end: nil)
  FactoryBot.create(:hour, volunteer: volunteers.last, hourable: group_assignment.group_offer,
    meeting_date: Faker::Date.between(group_assignment.period_start + 1, 2.days.ago))
  FactoryBot.create(:feedback, volunteer: volunteers.last, feedbackable: group_assignment,
    author_id: volunteers.last.user.id)
end
puts_model_counts('After GroupAssignment created', User, Volunteer, Feedback, Hour, GroupOffer,
  GroupAssignment, Department, Assignment, Client)

# Create ClientNotifications
if ClientNotification.count < 1
  superadmin = User.find_by(email: 'superadmin@example.com')
  [
    FactoryBot.create(:client_notification_seed, active: true, user: superadmin),
    2.times do
      FactoryBot.create(:client_notification_seed, active: false, user: superadmin)
    end
  ]
end
puts_model_counts('After ClientNotification created', User, Client, ClientNotification)

# make sure the state is correct, after stuff has beeen done via FactoryBot
Volunteer.accepted.map(&:verify_and_update_state)

puts_model_counts('Total Summup', GroupAssignmentLog, LanguageSkill, ReminderMailingVolunteer,
  Assignment, Contact, GroupOffer, PerformanceReport, User, BillingExpense, Department,
  GroupOfferCategory, Profile, Volunteer, Certificate, EmailTemplate, Hour, Relative, Client,
  Feedback, Import, ClientNotification, GroupAssignment, Journal, ReminderMailing)
