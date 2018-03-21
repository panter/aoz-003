class VolunteersController < ApplicationController
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes
  include VolunteerAttributes

  before_action :set_volunteer, only: [:show, :edit, :update, :terminate, :account]

  def index
    authorize Volunteer
    @q = policy_scope(Volunteer).ransack(params[:q])
    @q.sorts = ['acceptance asc'] if @q.sorts.empty?
    @volunteers = @q.result
    @volunteers = activity_filter
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
  end

  def new
    @volunteer = Volunteer.new
    authorize @volunteer
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    @volunteer.registrar = current_user
    authorize @volunteer
    if @volunteer.save
      if @volunteer.accepted?
        invite_volunteer_user
        redirect_to @volunteer, notice: t('volunteer_created_invite_sent',
          email: @volunteer.primary_email)
      else
        redirect_to @volunteer, notice: t('volunteer_created')
      end
    else
      render :new
    end
  end

  def update
    @volunteer.attributes = volunteer_params
    return render :edit unless @volunteer.valid?
    if handle_volunteer_update
      redirect_to volunteers_path, notice: t('invite_sent', email: @volunteer.primary_email)
    else
      redirect_to @volunteer, notice: t('volunteer_updated')
    end
  end

  def terminate
    if @volunteer.terminatable?
      @volunteer.terminate!
      redirect_back fallback_location: volunteers_url,
        notice: 'Freiwillige/r wurde erfolgreich beendet.'
    else
      redirect_back(fallback_location: volunteer_path(@volunteer), notice: resigned_fail_notice)
    end
  end

  def seeking_clients
    authorize Volunteer
    @q = policy_scope(Volunteer).seeking_clients.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @seeking_clients = @q.result.paginate(page: params[:page])
  end

  def account
    @volunteer.contact.primary_email = volunteer_params[:contact_attributes][:primary_email]
    if @volunteer.save
      invite_volunteer_user
      redirect_back(fallback_location: volunteer_path(@volunteer),
        notice: 'Freiwillige/r erhält eine Accountaktivierungs-Email.')
    elsif @volunteer.contact.errors.messages[:primary_email]
      redirect_to @volunteer, notice: {
        message: 'Die Mailadresse ist scheinbar nicht gültig',
        model_message: 'Für einen Useraccount wird eine gültige Email benötigt.',
        action_link: { text: 'Mailadresse konfigurieren', path: edit_volunteer_path(@volunteer) }
      }
    else
      redirect_to @volunteer, notice: 'Account erstellen fehlgeschlagen!'
    end
  end

  private

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
      action_link: { text: 'Begleitung bearbeiten', path: volunteer_path(@volunteer, anchor: 'assignments') }
    }
  end

  def activity_filter
    return @volunteers unless params[:q] && params[:q][:active_eq]
    params[:q][:active_eq] == 'true' ? @volunteers.active : @volunteers.inactive
  end

  def handle_volunteer_update
    if @volunteer.acceptance_change == ['undecided', 'accepted'] && @volunteer.user_id.blank?
      @volunteer.save && invite_volunteer_user
    else
      @volunteer.save!
      false
    end
  end

  def invite_volunteer_user
    return false if @volunteer.external
    new_user = User.new(
      email: @volunteer.contact.primary_email, password: Devise.friendly_token,
      role: 'volunteer', volunteer: @volunteer
    )
    new_user.save && new_user.invite!
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize @volunteer
  end

  def volunteer_params
    params.require(:volunteer).permit(volunteer_attributes, :bank, :iban, :waive, :acceptance,
      :take_more_assignments, :external, :comments, :additional_comments)
  end
end
