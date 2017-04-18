class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable
  has_many :clients
  has_one :profile

  # Roles definition
  SUPERADMIN = 'superadmin'.freeze
  ADMIN = 'admin'.freeze
  SOCIAL_WORKER = 'social_worker'.freeze
  ROLES = [SUPERADMIN, ADMIN, SOCIAL_WORKER].freeze

  def superadmin?
    role == User::SUPERADMIN
  end

  def admin?
    role == User::ADMIN
  end

  def admin_superadmin?
    role == User::ADMIN || role == User::SUPERADMIN
  end

  def social_worker?
    role == User::SOCIAL_WORKER
  end

  validates :role, inclusion: { in: ROLES }

  def self.create_user_and_send_password_reset(email:, role:)
    user = User.new(
      email: email, password: Devise.friendly_token, role: role
    )

    if user.save!
      user.send_reset_password_instructions
      logger.info "Mail sent to #{user.email}"
    end
  end

  def self.role_collection
    ROLES
  end
end
