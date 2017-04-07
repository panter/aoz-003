namespace :setup do
  desc "Create a superadmin user and send him a password reset mail"
  task superadmin: :environment do
    if ENV['email'].present?
      user = User.new(
        email: ENV['email'], password: Devise.friendly_token, role: 'superadmin'
      )

      if user.save!
        user.send_reset_password_instructions

        puts "Invitation sent to #{ user.email }"
      end
    else
      puts "No email set, run `rails setup:superadmin email=email@test.com`"
    end
  end
end
