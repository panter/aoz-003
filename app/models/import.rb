class Import < ApplicationRecord
  belongs_to :importable, polymorphic: true, optional: true
end
