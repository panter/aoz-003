class Assignment < ApplicationRecord
  belongs_to :client
  belongs_to :volunteer

  has_attached_file :agreement
  validates_attachment :agreement, content_type: { content_type: 'application/pdf' }
end
