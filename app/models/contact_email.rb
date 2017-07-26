class ContactEmail < ContactPoint
  validates :body, format: {
    with: Devise.email_regexp,
    message: 'Not an email address.'
  }

  LABELS = [:work, :home, :miscellaneous].freeze
end
