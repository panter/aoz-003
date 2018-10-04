class SemesterProcessMail < ApplicationRecord
  belongs_to :semester_process_volunteer
  belongs_to :sent_by, references: :users, class_name: 'User', inverse_of: 'semester_process_mails'

  enum kind: { mail: 0, reminder: 1 }

  scope :mail, -> { where(kind: 'mail') }
  scope :reminder, -> { where(kind: 'reminder') }
end
