class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable
  has_many :clients

  validates :role, inclusion: { in: ['superadmin'] }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def self.create_user_and_send_password_reset email:
    user = User.new(
      email: email, password: Devise.friendly_token, role: 'superadmin'
    )

    if user.save!
      user.send_reset_password_instructions
      puts "Mail sent to #{ user.email }"
    end
  end

end
