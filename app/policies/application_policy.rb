class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  delegate :superadmin?, to: :user, allow_nil: true
  delegate :department_manager?, to: :user
  delegate :social_worker?, to: :user
  delegate :volunteer?, to: :user

  def superadmin_or_social_worker?
    superadmin? || social_worker?
  end

  def superadmin_or_volunteer?
    superadmin? || volunteer?
  end

  def superadmin_or_department_manager?
    superadmin? || department_manager?
  end

  def department_manager_or_social_worker?
    department_manager? || social_worker?
  end

  def superadmin_or_department_manager_or_social_worker?
    superadmin? || department_manager? || social_worker?
  end

  def department_manager_offer?
    department_manager? && department_manager_offer_related?
  end

  def department_manager_offer_related?
    user.department.include?(record.department) || user.group_offers.include?(record)
  end

  def superadmin_or_department_manager_offer?
    superadmin? || department_manager_offer?
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def user_is_in?
    user.present?
  end

  def deny_all!
    false
  end

  def allow_all!
    true
  end

  def user_owns_record?
    record.class != Class && record.user_id == user.id
  end

  def user_owns_registration?
    record.class != Class && record.registrar_id == user.id
  end

  def volunteers_entry?
    volunteer? && record.author_id == user.id
  end

  def volunteer_related?
    volunteer? && record.volunteer.user_id == user.id
  end

  def volunteer_included?
    volunteer? && record.volunteers.include?(user.volunteer)
  end

  def superadmin_or_record_owner?
    superadmin? || user_owns_record?
  end

  def superadmin_or_department_managers_record?
    superadmin? || department_manager? && user_owns_record?
  end

  def superadmin_or_department_managers_registration?
    superadmin? || department_manager? && user_owns_registration?
  end

  def superadmin_or_user_in_records_related?
    superadmin? || record.user_ids.include?(user.id)
  end

  def superadmin_or_volunteers_record?
    superadmin? || volunteer? && user_owns_record?
  end

  def superadmin_or_volunteer_related?
    superadmin? || volunteer_related?
  end

  def superadmin_or_department_manager_creation?
    superadmin? || department_manager_creation?
  end

  def assignment_creator?
    record.assignment? && record.creator_id == user.id
  end

  def group_assignment_creator?
    record.group_assignment? && record.group_offer.creator_id == user.id
  end

  def department_manager_creation?
    department_manager? && (assignment_creator? || group_assignment_creator?)
  end

  def superadmin_or_department_manager_creation_or_volunteer_related?
    superadmin_or_department_manager_creation? || volunteer_related?
  end

  def superadmin_or_departments_offer_or_volunteer_included?
    superadmin_or_department_manager_offer? || volunteer_included?
  end

  def superadmin_or_volunteers_entry?
    superadmin? || volunteers_entry?
  end

  def superadmin_or_volunteers_feedback?
    superadmin? || volunteer? && of_and_from_volunteer? && in_feedbackable?
  end

  def superadmin_or_volunteers_trial_feedback?
    superadmin? || volunteer? && of_and_from_volunteer? && in_trial_feedbackable?
  end

  def of_and_from_volunteer?
    user.volunteer.id == record.volunteer.id && user.id == record.author.id
  end

  def in_feedbackable?
    if record.feedbackable.class == Assignment
      record.feedbackable.volunteer.id == user.volunteer.id
    else
      record.feedbackable.volunteers.ids.include? user.volunteer.id
    end
  end

  def in_trial_feedbackable?
    if record.trial_feedbackable.class == Assignment
      record.trial_feedbackable.volunteer.id == user.volunteer.id
    else
      record.trial_feedbackable.volunteers.ids.include? user.volunteer.id
    end
  end

  alias_method :index?,   :deny_all!
  alias_method :new?,     :deny_all!
  alias_method :create?,  :deny_all!
  alias_method :edit?,    :deny_all!
  alias_method :update?,  :deny_all!
  alias_method :destroy?, :deny_all!

  alias_method :home?,    :user_is_in?
end
