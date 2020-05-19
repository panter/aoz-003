class VolunteersController < ApplicationController
  include ProcessedByConcern
  before_action :set_volunteer, only: [:show, :edit, :update, :terminate, :account, :update_bank_details, :reactivate]
  before_action :set_active_and_archived_missions, only: [:show, :edit]

  def index
    authorize Volunteer
    @q = policy_scope(Volunteer).ransack(params[:q])
    @q.sorts = ['acceptance asc'] if @q.sorts.empty?
    @volunteers = @q.result
    respond_to do |format|
      format.xlsx { render xlsx: 'index', filename: 'Freiwilligen_Liste' }
      format.html { @volunteers = @volunteers.paginate(page: params[:page]) }
    end
  end

  def search
    authorize Volunteer
    @q = policy_scope(Volunteer).ransack contact_full_name_cont: params[:term]
    @volunteers = @q.result distinct: true
    respond_to do |format|
      format.json
    end
  end

  def show
    @volunteer_events = @volunteer.events.past

    @group_offer_categories = @volunteer.group_offer_categories.active.without_house_moving
    @group_offer_categories_house_moving = @volunteer.group_offer_categories.active.house_moving
  end

  def new
    @volunteer = Volunteer.new
    authorize @volunteer
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    @volunteer.registrar = current_user

    if current_user.department_manager? && volunteer_params[:department_id].blank?
      @volunteer.department = current_user.department&.last
    end

    authorize @volunteer

    if @volunteer.save
      if @volunteer.accepted? && @volunteer.internal? && @volunteer.user
        redirect_to edit_volunteer_path(@volunteer), notice: t('volunteer_created_invite_sent',
          email: @volunteer.primary_email)
      else
        redirect_to edit_volunteer_path(@volunteer), notice: t('volunteer_created')
      end
    else
      render :new
    end
  end

  def update
    @volunteer.attributes = volunteer_params
    return render :edit unless @volunteer.valid?

    register_acceptance_change(@volunteer)

    if @volunteer.will_save_change_to_attribute?(:acceptance, to: 'accepted') &&
        @volunteer.internal? && !@volunteer.user && @volunteer.save
      auto_assign_department!
      redirect_to(edit_volunteer_path(@volunteer),
        notice: t('invite_sent', email: @volunteer.primary_email))
    elsif @volunteer.save
      auto_assign_department! if @volunteer.saved_change_to_attribute?(:acceptance) && @volunteer.invited?
      redirect_to edit_volunteer_path(@volunteer), notice: t('volunteer_updated')
    else
      render :edit
    end
  end

  def update_bank_details
    authorize @volunteer
    @volunteer.update(volunteer_params.slice(:iban, :waive, :bank))
    render json: nil, status: :ok
  end

  def terminate
    if @volunteer.terminatable?
      @volunteer.terminate!(current_user)
      redirect_back fallback_location: edit_volunteer_path(@volunteer),
        notice: 'Freiwillige/r wurde erfolgreich beendet.'
    else
      redirect_back(fallback_location: edit_volunteer_path(@volunteer), notice: resigned_fail_notice)
    end
  end

  def seeking_clients
    authorize Volunteer
    @q = policy_scope(Volunteer).seeking_assignment_client.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @seeking_clients = @q.result.paginate(page: params[:page])
  end

  def account
    @volunteer.contact.primary_email = volunteer_params[:contact_attributes][:primary_email]
    if @volunteer.save && @volunteer.user&.invited_to_sign_up?
      @volunteer.invite_user if needs_reinvite?
      redirect_back(fallback_location: edit_volunteer_path(@volunteer),
        notice: 'Freiwillige/r erhält eine Accountaktivierungs-Email.')
    elsif @volunteer.contact.errors.messages[:primary_email]
      redirect_to @volunteer, notice: {
        message: 'Die Mailadresse ist scheinbar nicht gültig',
        model_message: 'Für einen Useraccount wird eine gültige Email benötigt.',
        action_link: { text: 'Mailadresse konfigurieren', path: edit_volunteer_path(@volunteer) }
      }
    else
      redirect_to edit_volunteer_path(@volunteer), notice: 'Account erstellen fehlgeschlagen!'
    end
  end

  def reactivate
    state = @volunteer.reactivate!(current_user) ? 'success' : 'failure'
    redirect_to edit_volunteer_path(@volunteer), notice: t("volunteers.notices.reactivation.#{state}")
  end

  private

  def auto_assign_department!
    return if !current_user.department_manager? || current_user.department.empty? || @volunteer.department.present?

    # association
    @volunteer.update(department: current_user.department.first)
  end

  def not_resigned
    return if params[:q]
    @volunteers = @volunteers.not_resigned
  end

  def resigned_fail_notice
    {
      message:
        'Beenden fehlgeschlagen.
        Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.
        Bitte sicherstellen, dass alle Einsätze komplett abgeschlossen sind.',
      model_message: @volunteer.errors.messages[:acceptance].first,
      action_link: { text: 'Begleitung bearbeiten', path: edit_volunteer_path(@volunteer, anchor: 'assignments') }
    }
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize @volunteer
  end

  def set_active_and_archived_missions
    @current_assignments = @volunteer.assignments.unterminated
    @archived_assignments = @volunteer.assignment_logs

    @current_group_assignments = @volunteer.group_assignments.unterminated
    @archived_group_assignments = @volunteer.group_assignment_logs
  end

  def volunteer_params
    params.require(:volunteer).permit policy(Volunteer).permitted_attributes
  end

  def needs_reinvite?
    params[:reinvite].presence == 'true'
  end
end
