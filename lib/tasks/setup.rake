namespace :setup do
  desc 'Create a superadmin user and send him a password reset mail'
  task superadmin: :environment do
    if ENV['email'].present?
      User.create_user_and_send_password_reset email: ENV['email'], role: 'superadmin'
    else
      warn 'No email set, run `rails setup:superadmin email=email@test.com`'
    end
  end

  desc 'Create staging initial superadmin users'
  task staging_user_init: :environment do
    [
      'superadmin@example.com', 'jeannine.stauffer@aoz.ch', 'emi@panter.ch',
      'zaida.haener@aoz.ch', 'zsolt@decoding.io', 'seb@panter.ch', 'anna.scheu@uzh.ch'
    ].each { |email| create_bulk_user(email, 'superadmin') }
    [
      'sozialarbeiterin@aoz.ch', 'seb+sozialarbeiter@panter.ch'
    ].each { |email| create_bulk_user(email, 'social_worker') }
    [
      'department_manager@example.com', 'seb+fwverantwortlich@panter.ch',
      'standortverantwortliche@aoz.ch'
    ].each { |email| create_bulk_user(email, 'department_manager') }
  end

  def create_bulk_user(email, role)
    user = User.create_user_and_send_password_reset email: email, role: role
    user.build_profile
    user.profile.build_contact
    user.profile.contact.assign_attributes(first_name: email, last_name: email,
      street: 'example_street', postal_code: '8000', primary_email: email,
      primary_phone: '000000')
    user.save!
  end

  desc 'Create Superadmin account ready to use (no activation needed)'
  task superadmin_initialized: :environment do
    if ENV['email'].present?
      FactoryBot.create(:user, email: ENV['email'], password: 'asdfasdf', role: 'superadmin')
    else
      warn 'No email set, run `rails setup:superadmin_initialized email=an.email@you-choose.com`'
    end
  end
end
