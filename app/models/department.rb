class Department < ApplicationRecord
  has_and_belongs_to_many :user
  accepts_nested_attributes_for :user, allow_destroy: true
end
