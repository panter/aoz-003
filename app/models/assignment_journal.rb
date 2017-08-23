class AssignmentJournal < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
end
