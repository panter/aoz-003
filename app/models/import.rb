class Import < ApplicationRecord
  belongs_to :importable, polymorphic: true, optional: true

  def self.get_imported(entity, access_id)
    find_by(importable_type: entity.name, access_id: access_id)&.importable
  end

  def self.find_by_hauptperson(hauptperson_id)
    find_by('store @> ?', { haupt_person: { pk_Hauptperson: hauptperson_id } }.to_json)
  end
end
