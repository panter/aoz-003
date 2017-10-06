class Feedback < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment
  belongs_to :author, class_name: 'User'
end
