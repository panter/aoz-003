class ClientNotification < ApplicationRecord

  before_save :ensure_exactly_one_active

  default_scope { order(created_at: :desc) }
  scope :active, -> { find_by(active: true) }

  belongs_to :user, -> { with_deleted }

  def ensure_exactly_one_active
    return unless active && changed.include?('active')
    ClientNotification.active.update(active: false)
  end
end
