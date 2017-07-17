class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  has_many :clients
  has_many :journals
  has_many :assignments, inverse_of: 'creator'
  has_one :profile, dependent: :destroy
  has_one :volunteer, dependent: :destroy
  has_and_belongs_to_many :department

  # Roles definition
  SUPERADMIN = 'superadmin'.freeze
  SOCIAL_WORKER = 'social_worker'.freeze
  DEPARTMENT_MANAGER = 'department_manager'.freeze
  VOLUNTEER = 'volunteer'.freeze
  ROLES_FOR_USER_CREATE = [SUPERADMIN, SOCIAL_WORKER, DEPARTMENT_MANAGER].freeze
  ROLES = ROLES_FOR_USER_CREATE + [VOLUNTEER]

  validates :role, inclusion: { in: ROLES }

  scope :department_assocable, (-> { where(role: [SUPERADMIN, DEPARTMENT_MANAGER]) })

  def superadmin?
    role == SUPERADMIN
  end

  def social_worker?
    role == SOCIAL_WORKER
  end

  def department_manager?
    role == DEPARTMENT_MANAGER
  end

  def volunteer?
    role == VOLUNTEER
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

  def to_label
    if profile && profile.contact
      "#{full_name} #{email}"
    else
      email
    end
  end

  def full_name
    if profile && profile.contact
      "#{profile.contact.first_name} #{profile.contact.last_name}"
    else
      email
    end
  end

  def self.role_collection
    ROLES_FOR_USER_CREATE.map(&:to_sym)
  end
end
