class Volunteer < ApplicationRecord
  acts_as_paranoid

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :first_name, :last_name, :email, presence: true

  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  def self.duration_collection
    [:short, :long]
  end

  def self.region_collection
    [:city, :region, :canton]
  end

  def self.single_accompaniment
    [:man, :woman, :family, :kid]
  end

  def self.group_accompaniment
    [:sport, :creative, :music, :culture, :training, :german_course]
  end
end
