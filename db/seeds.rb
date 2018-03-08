include ApplicationHelper

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
      relative.first_name = FFaker::Name.first_name
      relative.last_name = FFaker::Name.last_name
      relative.relation = random_relation
      relative.birth_year = FFaker::Time.between(18.years.ago, 85.years.ago)
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
      body: FFaker::Lorem.sentence(rand(2..5)),
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

# create Volunteers for each acceptance type
Volunteer.acceptance_collection.each do |acceptance|
  if ['undecided', 'rejected'].include?(acceptance)
    FactoryBot.create(:volunteer_seed, acceptance: acceptance, user_id: nil)
  else
    FactoryBot.create(:volunteer_seed_with_user, acceptance: acceptance)
  end
end
puts_model_counts('After Volunteer created', User, Volunteer, Client)

# create Clients for each acceptance type
Client.acceptance_collection_restricted.each do |acceptance|
  FactoryBot.create(:client, acceptance: acceptance, user: User.superadmins.first)
end
puts_model_counts('After Client created', User, Volunteer, Client)

# create EmailTemplates
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
  FactoryBot.create :email_template_termination, active: true
  2.times do
    FactoryBot.create :email_template_termination, active: false
  end
end
puts_model_counts('After EmailTemplates created', User, EmailTemplate)

def assignment_generator(creator, create_day, start_date = nil, end_date = nil, terminated_at: nil, volunteer: nil)
  volunteer ||= FactoryBot.create(:volunteer_seed_with_user, acceptance: 'accepted')
  volunteer.update(created_at: create_day, updated_at: create_day + 1)
  client = FactoryBot.create(:client, acceptance: 'accepted', user: creator)
  client.update(created_at: create_day - 5)
  start_date ||= FFaker::Time.between(create_day, create_day + 50)
  assignment = FactoryBot.create(:assignment, volunteer: volunteer, period_start: start_date,
    period_end: end_date, creator: creator,
    client: FactoryBot.create(:client, acceptance: 'accepted', user: creator))
  assignment.update(created_at: create_day)
  if terminated_at.present?
    assignment.update(period_end_set_by: creator, termination_submitted_by: assignment.volunteer.user,
      termination_submitted_at: FFaker::Time.between(end_date, terminated_at), termination_verified_by: creator,
      termination_verified_at: terminated_at)
  end
  assignment
end

def gemerate_feedback_and_hours(creator, hourable, start_date, end_date = nil, volunteer: nil)
  volunteer = volunteer || hourable.volunteer
  end_date = end_date&.to_date || 2.days.ago.to_date
  start_date = start_date.to_date
  meeting_date = FFaker::Time.between(start_date + 1, end_date).to_date
  hour = FactoryBot.create(:hour, volunteer: volunteer, hourable: hourable, meeting_date: meeting_date)
  hour.update(created_at: meeting_date + 1)
  feedback = FactoryBot.create(:feedback, volunteer: volunteer, feedbackable: hourable,
    author: volunteer.user)
  feedback.update(created_at: FFaker::Time.between(start_date + 1, end_date - 1))
  trial_feedback = FactoryBot.create(:trial_feedback, volunteer: volunteer, author: volunteer.user,
    trial_feedbackable: hourable)
  trial_feedback.update(created_at: FFaker::Time.between(start_date + 6*7, start_date + 8*7))
end


# create Assignments
if Assignment.count < 1
  # trial Assignments
  creator = User.superadmins.first
  3.times do
    start_date = FFaker::Time.between(6.weeks.ago, 8.weeks.ago).to_date
    assignment = assignment_generator(creator, start_date - 2, start_date)
    gemerate_feedback_and_hours(creator, assignment, start_date)
  end
  # half_year Assignments
  3.times do
    start_date = FFaker::Time.between(6.months.ago, 12.months.ago).to_date
    assignment = assignment_generator(creator, start_date - 2, start_date)
    gemerate_feedback_and_hours(creator, assignment, start_date)
  end
  # ended Assignments
  2.times do
    start_date = FFaker::Time.between(1.year.ago, 2.years.ago).to_date
    end_date = FFaker::Time.between(start_date + 100, 2.days.ago).to_date
    assignment = assignment_generator(creator, start_date - 10, start_date, end_date,
      terminated_at: end_date + 10)
    gemerate_feedback_and_hours(creator, assignment, start_date, end_date + 10)
  end

  # Generate last year assignment for performance report
  2.times do
    create_day = 1.year.ago.to_date + 2
    start_date = FFaker::Time.between(create_day, create_day + 50).to_date
    end_date = FFaker::Time.between(create_day + 100, 1.year.ago.end_of_year.to_date - 2).to_date
    assignment = assignment_generator(creator, start_date - 10, start_date, end_date,
      terminated_at: end_date + 10)
    gemerate_feedback_and_hours(creator, assignment, start_date, end_date + 10)
  end

  # started last year, ends this year
  create_day = 1.year.ago.beginning_of_year.to_date + 10
  start_date = FFaker::Time.between(create_day, create_day + 50).to_date
  end_date = FFaker::Time.between(Time.zone.now.beginning_of_year.to_date + 2, 3.days.ago).to_date
  assignment = assignment_generator(creator, create_day, start_date, end_date,
    terminated_at: end_date + 3)
  gemerate_feedback_and_hours(creator, assignment, start_date, end_date + 3)

  3.times do
    create_day = 2.years.ago.beginning_of_year.to_date + 10
    start_date = FFaker::Time.between(create_day, create_day + 50)
    end_date = FFaker::Time.between(create_day + 100, 2.years.ago.end_of_year.to_date - 2)
    assignment = assignment_generator(creator, create_day, start_date, end_date,
      terminated_at: end_date + 3)
    gemerate_feedback_and_hours(creator, assignment, start_date, end_date + 3)
  end
end
puts_model_counts('After Assignment created', User, Volunteer, Feedback, Hour, Assignment, Client,
  TrialFeedback)

Array.new(2).map { FactoryBot.create(:group_offer, department: Department.all.sample) }
     .each do |group_offer|
  creator = User.superadmins.first
  volunteers = Array.new(4).map { FactoryBot.create(:volunteer_seed_with_user, acceptance: 'accepted') }
  start_date = FFaker::Time.between(6.weeks.ago, 8.weeks.ago)
  group_assignment = GroupAssignment.create(volunteer: volunteers.first, group_offer: group_offer,
    period_start: start_date, period_end: nil)
  gemerate_feedback_and_hours(creator, group_assignment.group_offer, start_date, volunteer: volunteers.first)

  start_date = FFaker::Time.between(6.months.ago, 12.months.ago)
  group_assignment = GroupAssignment.create(volunteer: volunteers.second, group_offer: group_offer,
    period_start: start_date, period_end: nil)
  gemerate_feedback_and_hours(creator, group_assignment.group_offer, start_date, volunteer: volunteers.second)

  # ended GroupAssignments
  start_date = FFaker::Time.between(6.months.ago, 12.months.ago)
  end_date = FFaker::Time.between(1.week.ago, 3.days.ago)
  group_assignment = GroupAssignment.create(volunteer: volunteers.third, group_offer: group_offer,
    period_start: start_date, period_end: end_date)
  gemerate_feedback_and_hours(creator, group_assignment.group_offer, start_date, volunteer: volunteers.third)

  group_assignment = GroupAssignment.create(volunteer: volunteers.fourth, group_offer: group_offer,
    period_start: FFaker::Time.between(6.months.ago, 12.months.ago),
    period_end: FFaker::Time.between(1.week.ago, 3.days.ago))
  gemerate_feedback_and_hours(creator, group_assignment.group_offer, start_date, volunteer: volunteers.fourth)
end
puts_model_counts('After GroupAssignment created', User, Volunteer, Feedback, Hour, GroupOffer,
  GroupAssignment, Department, Assignment, Client)

# create ClientNotifications
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

# make sure the state is correct, after stuff has been done via FactoryBot
Volunteer.accepted.map(&:verify_and_update_state)

puts_model_counts('Total Summup', GroupAssignmentLog, LanguageSkill, ReminderMailingVolunteer,
  Assignment, Contact, GroupOffer, PerformanceReport, User, BillingExpense, Department,
  GroupOfferCategory, Profile, Volunteer, Certificate, EmailTemplate, Hour, Relative, Client,
  Feedback, Import, ClientNotification, GroupAssignment, Journal, ReminderMailing)
