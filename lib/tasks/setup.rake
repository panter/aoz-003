namespace :setup do
  desc 'Create a superadmin user and send him a password reset mail'
  task superadmin: :environment do
    if ENV['email'].present?
      User.create_user_and_send_password_reset email: ENV['email'], role: 'superadmin'
    else
      warn 'No email set, run `rails setup:superadmin email=email@test.com`'
    end
  end

  desc 'Create Superadmin account ready to use (no activation needed)'
  task superadmin_factory: :environment do
    if ENV['email'].present?
      FactoryGirl.create(:user, email: ENV['email'], password: 'asdfasdf', role: 'superadmin')
    else
      warn 'No email set, run `rails setup:superadmin_factory email=email@test.com`'
    end
  end
end
