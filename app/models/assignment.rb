class Assignment < ApplicationRecord
  belongs_to :client
  belongs_to :volunteer

  has_attached_file :agreement
end
