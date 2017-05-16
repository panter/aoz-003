class ContactEmail < ContactPoint
  def self.label_collection
    [:work, :home, :miscellaneous]
  end
end
