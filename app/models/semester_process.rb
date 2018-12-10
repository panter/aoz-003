class SemesterProcess < ApplicationRecord
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_processes'
  belongs_to :mail_posted_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_process_mails_posted', optional: true
  belongs_to :reminder_mail_posted_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_process_reminder_mail_posted', optional: true

  validates :semester, uniqueness: true

  has_many :semester_process_volunteers, dependent: :destroy
  accepts_nested_attributes_for :semester_process_volunteers, allow_destroy: true

  has_many :volunteers, through: :semester_process_volunteers
  has_many :semester_feedbacks, through: :semester_process_volunteers

  has_many :semester_process_volunteer_missions, through: :semester_process_volunteers

  has_many :semester_process_mails, through: :semester_process_volunteers

  attr_accessor :new_semester_process_volunteers, :kind

  scope :find_by_semester, lambda { |semester = nil|
    where('semester && daterange(?,?)', semester.begin, semester.end)
  }

  def hours
    semester_process_volunteers.map(&:hours).flatten
  end

  def mails
    semester_process_mails.where(kind: 'mail')
  end

  def reminders
    semester_process_mails.where(kind: 'reminder')
  end

  def subject
    if kind.to_sym == :reminder
      reminder_mail_subject_template
    else
      mail_subject_template
    end
  end

  def body
    if kind.to_sym == :reminder
      reminder_mail_body_template
    else
      mail_body_template
    end
  end

  # will only return an array, not a AD-result
  delegate :missions, to: :semester_process_volunteers

  # creates semester date range from string '[year],[semester_number]' e.g. '2018,2'
  def semester=(set_semester)
    set_semester = Semester.parse(set_semester) if set_semester.is_a?(String)

    # for very strange reason the end of the range is shifted one day after save
    # possibly a bug in Active Directory
    super(set_semester.begin..set_semester.end)
  end

  def semester_t(short: true)
    Semester.i18n_t(semester, short: short)
  end

  def semester_period
    Semester.period(semester)
  end

  def build_semester_volunteers(volunteers, selected: nil, save_records: false, preselect: false)
    volunteers = volunteers.select { |volunteer| selected.include? volunteer.id } if selected && selected.any?
    @new_semester_process_volunteers = []
    @new_semester_process_volunteers = volunteers.to_a.map do |volunteer|
      spv = SemesterProcessVolunteer.new(volunteer: volunteer, semester_process: self, selected: preselect)
      spv.build_missions(semester)
      spv.save if save_records && valid?
      spv
    end
  end

  def build_volunteers_feedbacks_and_mails(collection = nil)
    if collection
      SemesterProcessVolunteer.where(volunteer_id: collection).map do |spv|
        spv.build_mails(@kind)
      end
    else
      @new_semester_process_volunteers.map(&:build_mails)
    end
  end
end
