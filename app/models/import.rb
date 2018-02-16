class Import < ApplicationRecord
  belongs_to :importable, polymorphic: true, optional: true

  scope :assignment, (-> { polymorph_model(:assignment) })
  scope :billing_expense, (-> { polymorph_model(:billing_expense) })
  scope :certificate, (-> { polymorph_model(:certificate) })
  scope :client, (-> { polymorph_model(:client) })
  scope :department, (-> { polymorph_model(:department) })
  scope :group_assignment, (-> { polymorph_model(:group_assignment) })
  scope :group_offer, (-> { polymorph_model(:group_offer) })
  scope :group_offer_category, (-> { polymorph_model(:group_offer_category) })
  scope :hour, (-> { polymorph_model(:hour) })
  scope :journal, (-> { polymorph_model(:journal) })
  scope :volunteer, (-> { polymorph_model(:volunteer) })

  def self.get_imported(entity, access_id)
    find_by(importable_type: entity, access_id: access_id)&.importable
  end

  def self.find_by_hauptperson(hauptperson_id)
    find_by('store @> ?', { haupt_person: { pk_Hauptperson: hauptperson_id } }.to_json)
  end
end
