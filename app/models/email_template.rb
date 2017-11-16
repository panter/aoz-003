class EmailTemplate < ApplicationRecord
  enum kind: { Anmeldung: 0, Probezeit: 1, Tandem: 2, Groupenangebot: 3 }
  validates :kind, presence: true

  scope :default_order, -> { order(created_at: :desc) }
  scope :active_mail, -> { find_by(active: true) }

  def self.kind_collection
    kinds.keys.map(&:to_sym)
  end
end
