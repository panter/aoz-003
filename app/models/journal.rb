class Journal < ApplicationRecord
  belongs_to :user
  belongs_to :journalable, polymorphic: true, required: false
end
