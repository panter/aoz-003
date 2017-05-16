class Volunteer < ApplicationRecord
  acts_as_paranoid

  has_many :language_skills, as: :languageable, dependent: :destroy
  accepts_nested_attributes_for :language_skills, allow_destroy: true

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

  def self.human_boolean(boolean)
    boolean ? I18n.t('simple_form.yes') : I18n.t('simple_form.no')
  end

  def self.full_name(volunteer)
    "#{volunteer.first_name}, #{volunteer.last_name}"
  end
end
