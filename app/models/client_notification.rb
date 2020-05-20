class ClientNotification < ApplicationRecord
  before_save :ensure_exactly_one_active

  default_scope { order(created_at: :desc) }

  belongs_to :user, -> { with_deleted }

  def self.active
    where(active: true)
  end

  def ensure_exactly_one_active
    return unless active && changed.include?('active')

    ClientNotification.update(active: false)
  end
end
