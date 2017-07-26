class VolunteerEmail < ApplicationRecord
  before_save :ensure_exactly_one_active

  scope :active_mail, -> { find_by(active: true) }

  belongs_to :user

  def ensure_exactly_one_active
    return unless active && changed.include?('active')
    VolunteerEmail.active_mail.update(active: false)
  end
end
