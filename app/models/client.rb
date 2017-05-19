class Client < ApplicationRecord
  include AssociatableFields

  belongs_to :user

  validates :first_name, :last_name, presence: true

  def nationality_name
    return '' if nationality.blank?
    c = ISO3166::Country[nationality]
    c.translations[I18n.locale.to_s] || c.name
  end
end
