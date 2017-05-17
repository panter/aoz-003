class Relative < ApplicationRecord
  belongs_to :relativeable, polymorphic: true, optional: true
end
