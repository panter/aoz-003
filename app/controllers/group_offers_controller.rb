class GroupOffersController < ApplicationController
  include GroupAssignmentsAttributes
  before_action :set_group_offer, except: [:index, :search, :new, :create]
  before_action :set_department_manager_collection

  def index
    authorize GroupOffer
    set_default_filter(period_end_blank: 'true')
    @q = policy_scope(GroupOffer).ransack(params[:q])
    @q.sorts = ['active desc', 'created_at desc'] if @q.sorts.empty?
    @group_offers = @q.result
    respond_to do |format|
      format.html { @group_offers = @group_offers.paginate(page: params[:page]) }
      format.xlsx
    end
  end

  def search
    authorize GroupOffer
    @q = policy_scope(GroupOffer).ransack search_volunteer_cont: params[:term]
    @group_offers = @q.result distinct: true
    respond_to do |format|
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html do
        @q = policy_scope(Volunteer.candidates_for_group_offer(@group_offer)).ransack(params[:q])
        @volunteers = @q.result.paginate(page: params[:page])
      end

      format.pdf do
        render pdf: "group_offer_#{@group_offer.id}", layout: 'pdf.pdf',
        template: 'group_offers/show.pdf.slim', encoding: 'UTF-8'
      end
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
      redirect_to @group_offer, make_notice
    else
      render :new
    end
  end

  def update
    if @group_offer.update(group_offer_params)
      redirect_to @group_offer, make_notice
    else
      render :edit
    end
  end

  def change_active_state
    if @group_offer.update(active: !@group_offer.active)
      redirect_to group_offers_url,
        notice: @group_offer.active? ? t('.activated') : t('.deactivated')
    else
      redirect_to group_offers_url, notice: t('.no-change')
    end
  end

  def initiate_termination
    @group_offer.period_end = Time.zone.today
  end

  def submit_initiate_termination
    if @group_offer.update(period_end: group_offer_params[:period_end],
      period_end_set_by: current_user)
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
  end

  def group_offer_params
    params.require(:group_offer).permit(
      :title, :offer_type, :offer_state, :necessary_volunteers, :description,
      :women, :men, :children, :teenagers, :unaccompanied, :all, :long_term, :regular,
      :short_term, :workday, :weekend, :morning, :afternoon, :evening, :flexible, :schedule_details,
      :department_id, :creator_id, :organization, :location, :period_end, :group_offer_category_id,
      group_assignments_attributes
    )
  end
end
