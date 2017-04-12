namespace :setup do
  desc "Create a superadmin user and send him a password reset mail"
  task superadmin: :environment do
    if ENV['email'].present?
      User.create_user_and_send_password_reset email: ENV['email']
    else
      warn 'No email set, run `rails setup:superadmin email=email@test.com`'
    end
  end
end
