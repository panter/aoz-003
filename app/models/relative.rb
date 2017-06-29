class Relative < ApplicationRecord
  include FullName
  include YearCollection

  belongs_to :relativeable, polymorphic: true, optional: true
end
