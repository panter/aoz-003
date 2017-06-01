class Relative < ApplicationRecord
  include FullName

  has_and_belongs_to_many :relative, class_name: 'Person'

  has_one :person, as: :personable
  accepts_nested_attributes_for :person
end
