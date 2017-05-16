class ContactEmail < ContactPoint
  validates :body, format: {
    with: /\A[\w]+@[\w]{2,}\.[\w]{2,}\z/,
    message: 'Not an email address.'
  }

  def self.label_collection
    [:work, :home, :miscellaneous]
  end
end
