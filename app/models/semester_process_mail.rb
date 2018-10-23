class SemesterProcessMail < ApplicationRecord
  belongs_to :semester_process_volunteer
  belongs_to :sent_by, class_name: 'User', inverse_of: 'semester_process_mails'

  after_create :send_email

  enum kind: { mail: 0, reminder: 1 }

  scope :mail, -> { where(kind: 'mail') }
  scope :reminder, -> { where(kind: 'reminder') }

  delegate :volunteer, to: :semester_process_volunteer
  delegate :semester_process, to: :semester_process_volunteer


  TEMPLATE_VARNAMES = [
    :Anrede,
    :Name,
    :Einsatz,
    :FeedbackLink,
    :EmailAbsender,
    :Semester
  ].freeze

  def self.template_varnames
    {
      mail: TEMPLATE_VARNAMES,
      reminder: TEMPLATE_VARNAMES
    }
  end

  def process_template
    {
      subject: replace_ruby_template(self.subject),
      body: replace_ruby_template(self.body)
    }
  end

  def replace_ruby_template(template)
    template % template_variables
  end

  def template_variables
    template_variables = SemesterProcessMail::template_varnames[self.kind.to_sym].map do |varname|
      [varname, send(varname.to_s.underscore)]
    end.to_h
    template_variables.default = ''
    template_variables
  end

  def anrede
    I18n.t("salutation.#{volunteer.salutation}")
  end

  def name
    volunteer.contact.natural_name
  end

  def semester
    "#{ I18n.l(semester_process.semester.begin)} - #{I18n.l(semester_process.semester.end)}"
  end

  def einsatz
    ''
  end

  def email_absender
    "[#{reminder_mailing_creator_name}](mailto:"\
      "#{semester_process.creator.email})"
  end

  def reminder_mailing_creator_name
    semester_process.creator.profile&.contact&.natural_name ||
    semester_process.creator.email
  end

  def feedback_link
    "[Halbjahres-Rapport erstellen](#{feedback_url})"
  end

  def feedback_url(options = {})
    review_semester_semester_process_volunteer_path(semester_process_volunteer)
  end

  private

  def send_email
    VolunteerMailer.half_year_process_email(self).deliver
    self.update(sent_at: Time.zone.now)
  end
end
