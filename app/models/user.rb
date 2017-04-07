class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  has_one :profile

  validates :role, inclusion: { in: ['superadmin'] }
end
