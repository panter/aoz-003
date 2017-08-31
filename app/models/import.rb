class Import < ApplicationRecord
  belongs_to :importable, polymorphic: true, optional: true

  def self.get_imported(entity, access_id)
    find_by(importable_type: entity.to_s.classify, access_id: access_id).importable
  end
end
