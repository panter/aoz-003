class ContactPhone < ContactPoint
  LABELS = [:fax, :work, :home, :miscellaneous].freeze
  def self.label_collection
    [:fax, :work, :home, :miscellaneous]
  end
end
