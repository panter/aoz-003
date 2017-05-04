class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable
  has_many :clients

  has_one :profile, dependent: :destroy

  # Roles definition
  ADMIN = 'admin'.freeze
  DEPARTMENT_MANAGER = 'department_manager'.freeze
  SOCIAL_WORKER = 'social_worker'.freeze
  SUPERADMIN = 'superadmin'.freeze
  ROLE_COLLECTION = [ADMIN, DEPARTMENT_MANAGER, SOCIAL_WORKER, SUPERADMIN].freeze

  validates :role, inclusion: { in: ROLE_COLLECTION }, presence: true

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

  def self.create_user_and_send_password_reset(email:, role:)
    new_user = User.new(
      email: email, password: Devise.friendly_token, role: role
    )
    new_user.save! && new_user.send_reset_password_instructions
  end

  def self.role_collection
    ROLE_COLLECTION
  end
end
