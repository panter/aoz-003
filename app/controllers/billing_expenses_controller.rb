class BillingExpensesController < ApplicationController
  before_action :set_billing_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_volunteer

  def index
    billing_expense = BillingExpense.new(volunteer: @volunteer)
    authorize billing_expense
    @billing_expenses = BillingExpense.where(volunteer: @volunteer)
  end

  def show; end

  def new
    @billing_expense = BillingExpense.new(volunteer: @volunteer)
    authorize @billing_expense
  end

  def edit; end

  def create
    @billing_expense = BillingExpense
                       .new(billing_expense_params.merge(@volunteer.slice(:bank, :iban)))
    @billing_expense.user = current_user
    authorize @billing_expense
    if @billing_expense.save
      redirect_to @volunteer, make_notice
    else
      render :new
    end
  end

  def update
    if @billing_expense.update(billing_expense_params)
      redirect_to @volunteer, make_notice
    else
      render :edit
    end
  end

  def destroy
    @billing_expense.destroy
    redirect_to @volunteer, make_notice
  end

  private

  def set_billing_expense
    @billing_expense = BillingExpense.find(params[:id])
    authorize @billing_expense
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def billing_expense_params
    params.require(:billing_expense).permit(:amount, :bank, :iban, :state, :volunteer_id)
  end
end
