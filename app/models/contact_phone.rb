class ContactPhone < ContactPoint
  def self.label_collection
    [:fax, :work, :home, :miscellaneous]
  end
end
