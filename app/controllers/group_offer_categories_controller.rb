class GroupOfferCategoriesController < ApplicationController
  before_action :set_group_offer_category, only: [:show, :edit, :update]

  def index
    authorize GroupOfferCategory
    @q = GroupOfferCategory.all.ransack(params[:q])
    @group_offer_categories = @q.result
  end

  def show; end

  def new
    @group_offer_category = GroupOfferCategory.new
    authorize @group_offer_category
  end

  def edit; end

  def create
    @group_offer_category = GroupOfferCategory.new(group_offer_category_params)
    authorize @group_offer_category
    if @group_offer_category.save
      redirect_to group_offer_categories_url, make_notice
    else
      render :new
    end
  end

  def update
    if @group_offer_category.update(group_offer_category_params)
      redirect_to @group_offer_category, make_notice
    else
      render :edit
    end
  end

  private

  def set_group_offer_category
    @group_offer_category = GroupOfferCategory.find(params[:id])
    authorize @group_offer_category
  end

  def group_offer_category_params
    params.require(:group_offer_category).permit(
      :category_name, :category_state, :description, :group_offers_id
    )
  end
end
