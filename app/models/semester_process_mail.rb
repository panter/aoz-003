class SemesterProcessMail < ApplicationRecord
  belongs_to :semester_process_volunteer
  belongs_to :sent_by, class_name: 'User', inverse_of: 'semester_process_mails'

  after_create :send_email

  enum kind: { mail: 0, reminder: 1 }

  scope :mail, -> { where(kind: 'mail') }
  scope :reminder, -> { where(kind: 'reminder') }

  delegate :volunteer, to: :semester_process_volunteer
  delegate :semester_process, to: :semester_process_volunteer

  # Key is method name, value is users variable %{FeedbackLink}
  TEMPLATE_VARNAMES_GENERAL = {
    anrede: :Anrede,
    name: :Name,
    feedback_link: :FeedbackLink,
    email_absender: :EmailAbsender,
    online_plattform_url: :OnlinePlattformUrl,
    semester_from_to_date: :SemesterAnfangUndEndDatum
  }.freeze

  TEMPLATE_VARNAMES = {
    mail: TEMPLATE_VARNAMES_GENERAL,
    reminder: TEMPLATE_VARNAMES_GENERAL
  }.freeze

  def self.template_varnames(kind = :mail)
    TEMPLATE_VARNAMES[kind]
  end

  def template_varnames
    TEMPLATE_VARNAMES[kind.to_sym]
  end

  def process_template
    {
      subject: replace_ruby_template(subject),
      body: replace_ruby_template(body)
    }
  end

  private

  def send_email
    VolunteerMailer.half_year_process_email(self).deliver
    update!(sent_at: Time.zone.now)
  end

  def replace_ruby_template(template)
    template % template_variables
  end

  def template_variables
    template_variables = template_varnames.map do |method_name, var_name|
      [var_name, send(method_name)]
    end.to_h
    template_variables.default = ''
    template_variables
  end

  ## template variable converters
  #
  # there needs to be a method with the name matching each value
  # from SemesterProcessMail::TEMPLATE_VARNAMES
  # Otherwise there will be a method missing error if that template variable is used
  def anrede
    I18n.t("salutation.#{volunteer.salutation}")
  end

  def name
    volunteer.contact.natural_name
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

  def feedback_url
    Rails.application.routes.url_helpers.review_semester_review_semester_url(
      semester_process_volunteer,
      ActionMailer::Base.default_url_options
    )
  end

  def online_plattform_url
    "[Online-Plattform Url](#{Rails.application.routes.url_helpers.root_path})"
  end

  def semester_from_to_date
    semester = semester_process_volunteer.semester
    "#{I18n.l(semester.first)} bis #{I18n.l(semester.last)}}"
  end
end
