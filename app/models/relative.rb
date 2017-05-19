class Relative < ApplicationRecord
  include FullName

  belongs_to :relativeable, polymorphic: true, optional: true
end
