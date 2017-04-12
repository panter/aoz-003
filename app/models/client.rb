class Client < ApplicationRecord
  has_many :language_skills, dependent: :destroy
  has_many :relatives, dependent: :destroy
  belongs_to :user
  accepts_nested_attributes_for :language_skills, :relatives
  validates :firstname, presence: true
  validates :lastname, presence: true
end
