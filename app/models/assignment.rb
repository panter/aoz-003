class Assignment < ApplicationRecord
  include AssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  belongs_to :reactivated_by, class_name: 'User', inverse_of: 'reactivated_assignments',
    optional: true

  has_one :assignment_log, dependent: :nullify

  has_many :hours, as: :hourable
  has_many :feedbacks, as: :feedbackable

  # Semester process relations
  #
  has_many :semester_feedbacks, dependent: :destroy
  has_many :semester_process_volunteer_missions, dependent: :destroy
  has_many :semester_process_volunteers, through: :semester_process_volunteer_missions
  has_many :semester_processes, through: :semester_process_volunteers

  has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
  has_many :reminder_mailings, through: :reminder_mailing_volunteers

  validates :client_id, uniqueness: {
    scope: :volunteer_id, message: I18n.t('assignment_exists')
  }

  def polymorph_url_object
    self
  end

  def hours_since_last_submitted
    hours.since_last_submitted(submitted_at)
  end

  def feedbacks_since_last_submitted
    feedbacks.since_last_submitted(submitted_at)
  end

  def verify_termination(user)
    update(termination_verified_by: user, termination_verified_at: Time.zone.now)
    create_log_of_self
  end

  def create_log_of_self
    AssignmentLog.create(
      attributes.except(
        'id', 'created_at', 'updated_at',
        'pdf_file_name', 'pdf_content_type', 'pdf_file_size', 'pdf_updated_at', 'generate_pdf'
      ).merge(
        assignment_id: id
      )
    )
  end

  # allow ransack to use defined scopes
  def self.ransackable_scopes(auth_object = nil)
    ['active', 'inactive', 'active_or_not_yet_active']
  end

  def default_values
    self.agreement_text ||= default_agreement_text
  end

  def default_agreement_text
    <<~HEREDOC
      Freiwillige beachten folgende Grundsätze während ihres Einsatzes in der AOZ:
      * Verhaltenskodex für Freiwillige
      * Rechte und Pflichten für Freiwillige
      * AOZ Leitlinien Praktische Integrationsarbeit

      Allenfalls auch
      * Verpflichtungserklärung zum Schutz der unbegleiteten minderjährigen Asylsuchenden (MNA)
      * Niederschwellige Gratis-Deutschkurse: Informationen für freiwillige Kursleitende
    HEREDOC
  end
end
