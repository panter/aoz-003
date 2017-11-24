class ReminderMailing < ApplicationRecord
  belongs_to :creator, -> { with_deleted }, class_name: 'User'

  # nullify on delete in order to keep sent mail links available
  has_many :reminder_mailing_volunteers, dependent: :nullify
  accepts_nested_attributes_for :reminder_mailing_volunteers

  has_many :volunteers, through: :reminder_mailing_volunteers
  has_many :users, through: :volunteers

  has_many :assignments, through: :reminder_mailing_volunteers, source: :reminder_mailable,
    source_type: 'Assignment'
  has_many :group_assignments, through: :reminder_mailing_volunteers, source: :reminder_mailable,
    source_type: 'GroupAssignment'

  enum kind: { half_year: 0, probation_period: 1 }

  validate :no_reminder_volunteer_present, unless: :reminder_volunteer_mailings_any?
  validates :subject, presence: true
  validates :body, presence: true

  # setter generates relation to assignment/group_assignment and volunteer in one go
  def reminder_mailing_volunteers=(reminder_mailable)
    if [Assignment, GroupAssignment].include? reminder_mailable.first&.class
      super(reminder_mailable.map do |mailable|
        ReminderMailingVolunteer.new(volunteer: mailable.volunteer, reminder_mailable: mailable)
      end)
    else
      super(reminder_mailable)
    end
  end

  private

  def reminder_volunteer_mailings_any?
    reminder_mailing_volunteers.ids.any? || selected_volunteers_any?
  end

  def selected_volunteers_any?
    reminder_mailing_volunteers.map(&:selected).include?(true)
  end

  def no_reminder_volunteer_present
    errors.add(:volunteers, 'Es muss mindestens ein Freiwilliger ausgewählt sein.')
  end
end
