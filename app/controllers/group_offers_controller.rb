class GroupOffersController < ApplicationController
  include GroupAssignmentsAttributes
  before_action :set_group_offer, only: [:show, :edit, :update, :destroy, :change_active_state]
  before_action :set_assignable_collection, only: [:edit]
  before_action :set_volunteer_collection

  def index
    authorize GroupOffer
    @q = policy_scope(GroupOffer.active).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @group_offers = @q.result
    respond_to do |format|
      format.xlsx { render xlsx: 'index', locals: { group_offers: @group_offers } }
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "group_offer_#{@group_offer.id}", layout: 'pdf.pdf',
        template: 'group_offers/show.html.slim', encoding: 'UTF-8'
      end
    end
  end

  def new
    @group_offer = GroupOffer.new(creator: current_user)
    @group_offer.department = current_user.department.first if current_user.department_manager?
    authorize @group_offer
  end

  def edit; end

  def create
    @group_offer = GroupOffer.new(group_offer_params)
    @group_offer.creator = current_user
    @group_offer.department ||= current_user.department.first if current_user.department_manager?
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

  def destroy
    @group_offer.destroy
    redirect_to group_offers_url, make_notice
  end

  def archived
    authorize GroupOffer
    @q = policy_scope(GroupOffer.archived).ransack(params[:q])
    @archived = @q.result
    respond_to do |format|
      format.xlsx { render xlsx: 'index', locals: { group_offers: @archived } }
      format.html
    end
  end

  def change_active_state
    if @group_offer.update(active: !@group_offer.active)
      if @group_offer.active?
        redirect_to group_offers_url, notice: t('.activated')
      else
        redirect_to archived_group_offers_url, notice: t('.deactivated')
      end
    else
      redirect_to group_offers_url, notice: t('.no-change')
    end
  end

  private

  def set_group_offer
    @group_offer = GroupOffer.find(params[:id])
    authorize @group_offer
  end

  def set_assignable_collection
    set_volunteer_collection
    @assignable = if @group_offer.volunteer_state == 'internal_volunteer'
                    define_assignables(@internals)
                  else
                    define_assignables(@externals)
                  end
    @assignable += @group_offer.volunteers.map { |volunteer| [volunteer.contact.full_name, volunteer.id] }
    @assignable.uniq!
  end

  def define_assignables(volunteers)
    VolunteerPolicy::Scope.new(current_user, volunteers).resolve.map do |volunteer|
      [volunteer.contact.full_name, volunteer.id]
    end
  end

  def set_volunteer_collection
    @internals = Volunteer.internal
    @externals = Volunteer.external
  end

  def group_offer_params
    params.require(:group_offer).permit(:title, :offer_type, :offer_state, :volunteer_state,
      :necessary_volunteers, :description, :women, :men, :children, :teenagers, :unaccompanied,
      :all, :long_term, :regular, :short_term, :workday, :weekend, :morning, :afternoon, :evening,
      :flexible, :schedule_details, :department_id, :organization, :location,
      :group_offer_category_id, group_assignments_attributes)
  end
end
