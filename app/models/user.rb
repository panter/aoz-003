class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  has_many :clients

  has_one :person, as: :personable
  accepts_nested_attributes_for :person

  has_and_belongs_to_many :department

  # Roles definition
  SUPERADMIN = 'superadmin'.freeze
  SOCIAL_WORKER = 'social_worker'.freeze
  DEPARTMENT_MANAGER = 'department_manager'.freeze
  ROLES = [SUPERADMIN, SOCIAL_WORKER, DEPARTMENT_MANAGER].freeze

  validates :role, inclusion: { in: ROLES }

  scope :department_assocable, (-> { where(role: [SUPERADMIN, DEPARTMENT_MANAGER]) })

  def superadmin?
    role == User::SUPERADMIN
  end

  def social_worker?
    role == User::SOCIAL_WORKER
  end

  def department_manager?
    role == User::DEPARTMENT_MANAGER
  end

  def superadmin_or_department_manager?
    superadmin? || department_manager?
  end

  def with_department?
    department.first.present?
  end

  def self.create_user_and_send_password_reset(email:, role:)
    new_user = User.new(
      email: email, password: Devise.friendly_token, role: role
    )
    new_user.save! && new_user.send_reset_password_instructions
  end

  def to_s
    email
  end

  def self.role_collection
    ROLES.map(&:to_sym)
  end
end
