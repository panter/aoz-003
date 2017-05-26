class ContactEmail < ContactPoint
  validates :body, format: {
    with: Devise.email_regexp,
    message: 'Not an email address.'
  }

  def self.label_collection
    [:work, :home, :miscellaneous]
  end
end
