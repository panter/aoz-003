class GroupOffersController < ApplicationController
  before_action :set_group_offer, only: [:show, :edit, :update, :destroy, :change_active_state]

  def index
    authorize GroupOffer
    @q = policy_scope(GroupOffer).ransack(params[:q])
    @group_offers = @q.result
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
    @group_offer = GroupOffer.new
    authorize @group_offer
  end

  def edit; end

  def create
    @group_offer = GroupOffer.new(group_offer_params)
    @group_offer.department = current_user.department.first if current_user.manages_department?
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
    @q = GroupOffer.archived.ransack(params[:q])
    @archived = @q.result
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
    @group_offer = GroupOffer.unscoped.find(params[:id])
    authorize @group_offer
  end

  def group_offer_params
    params.require(:group_offer).permit(:title, :offer_type, :offer_state, :volunteer_state,
      :necessary_volunteers, :volunteer_responsible_state, :description, :women, :men, :children,
      :teenagers, :unaccompanied, :all, :long_term, :regular, :short_term, :workday, :weekend,
      :morning, :afternoon, :evening, :flexible, :schedule_details, :department_id, :organization,
      :location, :group_offer_category_id, :responsible_id, volunteer_ids: [])
  end
end
