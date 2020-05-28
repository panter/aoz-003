class Profile < ApplicationRecord
  include BuildContactRelation

  has_one :contact, -> { with_deleted }, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  delegate :full_name, to: :contact

  belongs_to :user, -> { with_deleted }

  has_one_attached :avatar

  validates :avatar, content_type: ext_mimes(:jpg, :gif, :png, :tif, :webp)

  def avatar_thumb
    avatar.variant(resize: '100x100>').processed
  end
end
