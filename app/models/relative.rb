class Relative < ApplicationRecord
  include FullName
  include YearCollection

  belongs_to :relativeable, polymorphic: true, optional: true

  def to_s
    [full_name, date_of_birth.try(:year), relation].reject(&:blank?).join(', ')
  end
end
