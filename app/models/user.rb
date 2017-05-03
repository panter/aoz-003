class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable
  has_many :clients

  has_one :profile, dependent: :destroy

  # Roles definition
  SUPERADMIN = 'superadmin'.freeze
  ADMIN = 'admin'.freeze
  SOCIAL_WORKER = 'social_worker'.freeze
  DEPARTMENT_MANAGER = 'department_manager'.freeze
  ROLES = [SUPERADMIN, ADMIN, SOCIAL_WORKER, DEPARTMENT_MANAGER].freeze

  def superadmin?
    role == User::SUPERADMIN
  end

  def admin?
    role == User::ADMIN
  end

  def admin_or_superadmin?
    role == User::ADMIN || role == User::SUPERADMIN
  end

  def social_worker?
    role == User::SOCIAL_WORKER
  end

  def staff?
    admin_or_superadmin? || social_worker?
  end

  validates :role, inclusion: { in: ROLES }

  def self.create_user_and_send_password_reset(email:, role:)
    new_user = User.new(
      email: email, password: Devise.friendly_token, role: role
    )
    new_user.save! && new_user.send_reset_password_instructions
  end

  def self.role_collection
    ROLES
  end
end
