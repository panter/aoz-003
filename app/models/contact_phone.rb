class ContactPhone < ContactPoint
  validates :body, format: {
    with: /\A[\ 0-9\+\-\_\(\)]{5,}\z/,
    message: 'Not a phone number'
  }

  def self.label_collection
    [:fax, :work, :home, :miscellaneous]
  end
end
