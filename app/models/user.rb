class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  validates :role, inclusion: { in: ['superadmin'] }
end
