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

def assignment_generator(create_day, start_date = nil, end_date = nil, terminated_at: nil, volunteer: nil)
  creator = User.superadmins.first
  volunteer ||= FactoryBot.create(:volunteer_seed)
  volunteer.update(created_at: create_day, updated_at: create_day + 1.day)
  client = FactoryBot.create(:client, acceptance: 'accepted', user: creator)
  client.update(created_at: create_day - 5.days)
  start_date ||= FFaker::Time.between(create_day, create_day + 50.days)
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

def generate_feedback_and_hours(hourable, start_date, end_date = nil, volunteer: nil)
  volunteer ||= hourable.volunteer
  end_date ||= 2.days.ago
  meeting_date = FFaker::Time.between(start_date + 1.day, end_date)
  hour = FactoryBot.create(:hour, volunteer: volunteer, hourable: hourable, meeting_date: meeting_date)
  hour.update(created_at: meeting_date + 1.day)
  feedback = FactoryBot.create(:feedback, volunteer: volunteer, feedbackable: hourable,
    author: volunteer.user)
  feedback.update(created_at: FFaker::Time.between(start_date + 1.day, end_date - 1.day))
  trial_feedback = FactoryBot.create(:trial_feedback, volunteer: volunteer, author: volunteer.user,
    trial_feedbackable: hourable)
  trial_feedback.update(created_at: FFaker::Time.between(start_date + 6.weeks, start_date + 8.weeks))
end

def handle_reminder_mailing_seed(mailer_type, reminder_mailables)
  reminder_mailing = FactoryBot.create(:reminder_mailing, mailer_type, reminder_mailing_volunteers: reminder_mailables)

  reminder_mailing.reminder_mailing_volunteers.each do |mailing_volunteer|
    mailing_volunteer.update(picked: true)
    VolunteerMailer.public_send(reminder_mailing.kind.to_sym, mailing_volunteer).deliver
  end
  reminder_mailing.update(sending_triggered: true)
end

def development_seed
  FactoryBot.create(:department_manager, email: "department_manager#{EMAIL_DOMAIN}",
      password: 'asdfasdf')
  FactoryBot.create(:volunteer).user
    .update(password: 'asdfasdf', email: "volunteer#{EMAIL_DOMAIN}")
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

  # create Volunteers for each acceptance type
  Volunteer.acceptance_collection.each do |acceptance|
    if ['undecided', 'rejected'].include?(acceptance)
      FactoryBot.create(:volunteer_seed, acceptance: acceptance, user_id: nil)
    else
      FactoryBot.create(:volunteer_seed)
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
    FactoryBot.create :email_template_signup, active: true
    2.times do
      FactoryBot.create :email_template_signup, active: false
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

  # create Assignments
  if Assignment.count < 1
    creator = User.superadmins.first
    # trial Assignments
    trial_assignments = (1..3).to_a.map do
      start_date = FFaker::Time.between(6.weeks.ago, 8.weeks.ago)
      assignment = assignment_generator(start_date - 2.days, start_date)
      generate_feedback_and_hours(assignment, start_date)
      assignment
    end
    handle_reminder_mailing_seed(:trial_period, trial_assignments)
    # half_year Assignments
    half_year_assignments = (1..3).to_a.map do
      start_date = FFaker::Time.between(6.months.ago, 12.months.ago)
      assignment = assignment_generator(start_date - 2.days, start_date)
      generate_feedback_and_hours(assignment, start_date)
      assignment
    end
    handle_reminder_mailing_seed(:half_year, half_year_assignments)
    # ended Assignments
    termination_assignments = (1..3).to_a.map do
      start_date = FFaker::Time.between(1.year.ago, 2.years.ago)
      end_date = FFaker::Time.between(start_date + 100.days, 2.days.ago)
      assignment = assignment_generator(start_date - 10.days, start_date, end_date,
        terminated_at: end_date + 10.days)
      generate_feedback_and_hours(assignment, start_date, end_date + 10.days)
      assignment
    end
    handle_reminder_mailing_seed(:termination, termination_assignments)

    # Generate last year assignment for performance report
    2.times do
      create_day = 1.year.ago + 2.days
      start_date = FFaker::Time.between(create_day, create_day + 50.days)
      end_date = FFaker::Time.between(create_day + 100.days, 1.year.ago.end_of_year - 2.days)
      assignment = assignment_generator(start_date - 10.days, start_date, end_date,
        terminated_at: end_date + 10.days)
      generate_feedback_and_hours(assignment, start_date, end_date + 10.days)
    end

    # started last year, ends this year
    create_day = 1.year.ago.beginning_of_year + 10.days
    start_date = FFaker::Time.between(create_day, create_day + 50.days)
    end_date = FFaker::Time.between(Time.zone.now.beginning_of_year + 2.days, 3.days.ago)
    assignment = assignment_generator(create_day, start_date, end_date,
      terminated_at: end_date + 3.days)
    generate_feedback_and_hours(assignment, start_date, end_date + 3.days)

    3.times do
      create_day = 2.years.ago.beginning_of_year + 10.days
      start_date = FFaker::Time.between(create_day, create_day + 50.days)
      end_date = FFaker::Time.between(create_day + 100.days, 2.years.ago.end_of_year - 2.days)
      assignment = assignment_generator(create_day, start_date, end_date,
        terminated_at: end_date + 3.days)
      generate_feedback_and_hours(assignment, start_date, end_date + 3.days)
    end
  end
  puts_model_counts('After Assignment created', User, Volunteer, Feedback, Hour, Assignment, Client,
    TrialFeedback)

  Array.new(2)
    .map { FactoryBot.create(:group_offer, department: Department.all.sample) }
    .each do |group_offer|
    creator = User.superadmins.first
    volunteers = Array.new(4).map { FactoryBot.create(:volunteer_seed) }
    start_date = FFaker::Time.between(6.weeks.ago, 8.weeks.ago)
    group_assignment = GroupAssignment.create(volunteer: volunteers.first, group_offer: group_offer,
      period_start: start_date, period_end: nil)
    generate_feedback_and_hours(group_assignment.group_offer, start_date, volunteer: volunteers.first)
    handle_reminder_mailing_seed(:trial_period, [group_assignment])

    start_date = FFaker::Time.between(6.months.ago, 12.months.ago)
    group_assignment = GroupAssignment.create(volunteer: volunteers.second, group_offer: group_offer,
      period_start: start_date, period_end: nil)
    generate_feedback_and_hours(group_assignment.group_offer, start_date, volunteer: volunteers.second)
    handle_reminder_mailing_seed(:half_year, [group_assignment])

    # ended GroupAssignments
    start_date = FFaker::Time.between(6.months.ago, 12.months.ago)
    end_date = FFaker::Time.between(1.week.ago, 3.days.ago)
    group_assignment = GroupAssignment.create(volunteer: volunteers.third, group_offer: group_offer,
      period_start: start_date, period_end: end_date)
    generate_feedback_and_hours(group_assignment.group_offer, start_date, volunteer: volunteers.third)
    handle_reminder_mailing_seed(:termination, [group_assignment])

    group_assignment = GroupAssignment.create(volunteer: volunteers.fourth, group_offer: group_offer,
      period_start: FFaker::Time.between(6.months.ago, 12.months.ago),
      period_end: FFaker::Time.between(1.week.ago, 3.days.ago))
    generate_feedback_and_hours(group_assignment.group_offer, start_date, volunteer: volunteers.fourth)
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
  Volunteer.accepted.each(&:verify_and_update_state)
  Volunteer.joins(:user).accepted.each do |volunteer|
    volunteer.user.accept_invitation
    volunteer.user.update(last_sign_in_at: 2.weeks.ago, password: 'asdfasdf')
  end

  puts_model_counts('Total Summup', GroupAssignmentLog, LanguageSkill, ReminderMailingVolunteer,
    Assignment, Contact, GroupOffer, PerformanceReport, User, BillingExpense, Department,
    GroupOfferCategory, Profile, Volunteer, Certificate, EmailTemplate, Hour, Relative, Client,
    Feedback, Import, ClientNotification, GroupAssignment, Journal, ReminderMailing)
end

DEFAULT_TEMPLATES_EMAIL_TEMPLATES = [
  {
    subject: 'Rückmeldung zur Beendigung von %{Einsatz}',
    body: "Liebe/r %{Anrede} %{Name}\r\n\r\nWir bitten Sie um eine Rückmeldung bezüglich der Beendigung von %{Einsatz}.\r\nBitte tragen Sie Ihre Rückmeldung hier ein:%{FeedbackLink}\r\n\r\nFreundliche Grüsse\r\n\r\nAOZ Fachstelle Freiwilligenarbeit\r\n",
    kind: 'termination',
    active: true
  },
  {
    subject: 'Probezeit Rückmeldung zu %{Einsatz}',
    body: "Liebe/r %{Anrede} %{Name}\r\n\r\nWir bitten Sie um eine Probezeit Rückmeldung bezüglich %{Einsatz}.\r\nBitte tragen Sie Ihre Rückmeldung hier ein:%{FeedbackLink}\r\n\r\nFreundliche Grüsse\r\n\r\nAOZ Fachstelle Freiwilligenarbeit\r\n",
    kind: 'trial', active: true
  },
  {
    subject: 'Vielen Dank für Ihre Anmeldung',
    body: "Liebe/r Freiwillige/r\r\n\r\nIhre Anmeldung wurde erfolgreich an uns abgeschickt. Wir freuen uns, dass Sie sich für einen freiwilligen Einsatz bei der AOZ interessieren.\r\n\r\n Wir werden uns bald bei Ihnen melden.\r\n\r\nFreundliche Grüsse\r\n\r\nAOZ Fachstelle Freiwilligenarbeit\r\n",
    kind: 'signup',
    active: true
  },
  {
    subject: 'Halbjährliche Rückmeldung zu %{Einsatz}',
    body: "Liebe/r %{Anrede} %{Name}\r\n\r\nWir bitten Sie um eine Halbjährliche Rückmeldung bezüglich %{Einsatz}.\r\nBitte tragen Sie Ihre Rückmeldung hier ein:%{FeedbackLink}\r\n\r\nFreundliche Grüsse\r\n\r\nAOZ Fachstelle Freiwilligenarbeit\r\n",
    kind: 'half_year',
    active: true
  }
].freeze

DEFAULT_GROUP_OFFER_CATEGORIES = [
  { category_name: 'Animation F' },
  { category_name: 'Kurzeinsatz' },
  { category_name: 'Andere' },
  { category_name: 'Deutschkurs' },
  { category_name: 'Bildung' },
  { category_name: 'Kultur' },
  { category_name: 'Musik' },
  { category_name: 'Kreativ' },
  { category_name: 'Sport' },
  { category_name: 'Kinderbetreuung' },
  { category_name: 'Freizeit' },
  { category_name: 'Bewerbungswerkstatt' },
  { category_name: 'Hausaufgabenhilfe' },
  { category_name: 'Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt' }
].freeze

def production_seed
  DEFAULT_TEMPLATES_EMAIL_TEMPLATES.each do |template_params|
    EmailTemplate.find_or_create_by(template_params)
  end

  DEFAULT_GROUP_OFFER_CATEGORIES.each do |category_param|
    go_category = GroupOfferCategory.find_or_create_by!(category_param)
    go_category.update(category_state: 'active')
  end
end

production_seed if Rails.env.production?
development_seed if Rails.env.development?
