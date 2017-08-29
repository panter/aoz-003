module ImportRelation
  extend ActiveSupport::Concern

  included do
    has_one :import, as: :importable, dependent: :destroy
    accepts_nested_attributes_for :import, allow_destroy: true
  end
end
