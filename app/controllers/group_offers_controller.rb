class GroupOffersController < ApplicationController
  before_action :set_group_offer, only: [:show, :edit, :update, :destroy]

  def index
    authorize GroupOffer
    @group_offers = policy_scope(GroupOffer)
  end

  def show; end

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

  private

  def set_group_offer
    @group_offer = GroupOffer.find(params[:id])
    authorize @group_offer
  end

  def group_offer_params
    params.require(:group_offer).permit(:title, :offer_state, :volunteer_state,
      :necessary_volunteers, :volunteer_responsible_state, :description, :women, :men, :children,
      :teenagers, :unaccompanied, :all, :long_term, :regular, :short_term, :workday, :weekend,
      :morning, :afternoon, :evening, :flexible, :date_time, :department_id, :organization)
  end
end
