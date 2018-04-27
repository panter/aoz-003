class Assignment < ApplicationRecord
  include AssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  has_many :hours, as: :hourable
  has_many :feedbacks, as: :feedbackable
  has_many :trial_feedbacks, as: :trial_feedbackable
  has_one :assignment_log

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
      attributes.except('id', 'created_at', 'updated_at').merge(assignment_id: id)
    )
  end

  # allow ransack to use defined scopes
  def self.ransackable_scopes(auth_object = nil)
    ['active', 'inactive', 'active_or_not_yet_active']
  end

  def involved_authority_contact
    involved_authority&.contact
  end

  def involved_authority
    if client.involved_authority
      client.involved_authority.profile
    else
      creator.profile
    end
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
