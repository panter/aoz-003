class Volunteer < ApplicationRecord
  def nationality_name
    return '' if nationality.blank?
    c = ISO3166::Country[nationality]
    c.translations[I18n.locale.to_s] || c.name
  end
end
