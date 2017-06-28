module AssociateRelatives
  extend ActiveSupport::Concern

  included do
    has_many :relatives, as: :relativeable, dependent: :destroy
    accepts_nested_attributes_for :relatives, allow_destroy: true
  end
end
