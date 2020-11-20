class GroupOffersController < ApplicationController
  before_action :set_group_offer, except: [:index, :search, :new, :create]
  before_action :set_department_manager_collection
  before_action :set_volunteers, only: [:edit, :show, :update]

  def index
    authorize GroupOffer
    set_default_filter(period_end_blank: 'true')
    @q = policy_scope(GroupOffer).ransack(params[:q])
    @q.sorts = ['active desc', 'created_at desc'] if @q.sorts.empty?
    @group_offers = @q.result
    respond_to do |format|
      format.html { @group_offers = @group_offers.paginate(page: params[:page]) }
      format.xlsx do
        render xlsx: 'index', filename: "Gruppenangebote_#{Time.zone.now.strftime('%Y-%m-%dT%H%M%S')}"
      end
    end
  end

  def search
    authorize GroupOffer
    @q = policy_scope(GroupOffer).ransack params[:q]
    @q.sorts = ['active desc', 'created_at desc']
    @group_offers = @q.result
    respond_to do |format|
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: pdf_file_name(@group_offer),
                layout: 'pdf_layout.pdf.slim',
                zoom: 1.5,
                dpi: 600,
                margin: { top: 10, bottom: 10, left: 0, right: 0 },
                template: 'group_offers/show.pdf.slim'
      end
    end
  end

  def search_volunteer
    @q = policy_scope(
      Volunteer.candidates_for_group_offer(@group_offer)
    ).ransack(params[:q])
    @volunteers = @q.result distinct: true
    respond_to do |format|
      format.json
    end
  end

  def new
    @group_offer = GroupOffer.new
    authorize @group_offer
  end

  def edit; end

  def create
    @group_offer = GroupOffer.new(group_offer_params)
    @group_offer.creator ||= current_user
    @group_offer.department ||= current_user.department&.first
    authorize @group_offer
    if @group_offer.save
      redirect_to edit_group_offer_path(@group_offer), make_notice
    else
      render :new
    end
  end

  def update
    if @group_offer.update(group_offer_params)
      if policy(@group_offer).edit?
        redirect_to edit_group_offer_path(@group_offer), make_notice
      else
        redirect_to group_offer_path(@group_offer), make_notice
      end
    else
      render :edit
    end
  end

  def change_active_state
    if @group_offer.update(active: !@group_offer.active)
      redirect_back fallback_location: group_offer_path(@group_offer),
        notice: @group_offer.active? ? t('.activated') : t('.deactivated')
    else
      redirect_back fallback_location: group_offer_path(@group_offer),
        notice: t('.no-change')
    end
  end

  def initiate_termination
    @group_offer.period_end = Time.zone.today
  end

  def submit_initiate_termination
    if @group_offer.update(
      period_end: group_offer_params[:period_end],
      period_end_set_by: current_user,
      active: false
    )
      redirect_to group_offers_path, notice: 'Gruppenangebots Beendigung erfolgreich eingeleitet.'
    else
      render :initiate_termination
    end
  end

  def end_all_assignments
    @group_offer.group_assignments.running.each do |group_assignment|
      group_assignment.update(
        period_end: group_offer_params['group_assignments_attributes']['0']['period_end'],
        period_end_set_by: current_user
      )
    end
    redirect_to initiate_termination_group_offer_path(@group_offer),
                notice: 'Gruppeneinsätze wurden beendet.'
  end

  private

  def set_group_offer
    @group_offer = GroupOffer.find(params[:id])
    authorize @group_offer
  end

  def set_department_manager_collection
    @department_managers = User.department_managers
    @department_managers = @department_managers.or(User.where(id: @group_offer.creator_id)) if @group_offer
  end

  def set_volunteers
    @q = policy_scope(Volunteer.candidates_for_group_offer(@group_offer)).ransack(params[:q])
    @volunteers = @q.result.paginate(page: params[:page])
  end

  def group_offer_params
    group_offer = defined?(@group_offer) ? @group_offer : GroupOffer
    params.require(:group_offer).permit policy(group_offer).permitted_attributes
  end
end
