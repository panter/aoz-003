class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  validates :role, inclusion: { in: ['superadmin'] }

  def self.create_user_and_send_password_reset email:
    user = User.new(
      email: email, password: Devise.friendly_token, role: 'superadmin'
    )

    if user.save!
      user.send_reset_password_instructions
      puts "Mail sent to #{ user.email }"
    end
  end

  def password_required?
    super if confirmed?
  end
end
