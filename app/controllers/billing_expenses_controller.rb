class BillingExpensesController < ApplicationController
  before_action :set_billing_expense, only: [:show, :destroy]
  before_action :set_volunteer
  before_action :set_volunteer_hours, only: :create
  after_action :volunteer_hours_update, only: :create

  def index
    authorize BillingExpense
    @billing_expenses = BillingExpense.where(volunteer: @volunteer)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "volunteers/#{@volunteer.id}/billing_expenses/#{@billing_expense.id}", template: 'billing_expenses/show.html.slim',
          layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end

  def new
    @billing_expense = BillingExpense.new(volunteer: @volunteer)
    authorize @billing_expense
  end

  def create
    @billing_expense = BillingExpense
                       .new(billing_expense_params.merge(@volunteer.slice(:bank, :iban)))
    @billing_expense.user = current_user
    @billing_expense.amount = compute_hours
    authorize @billing_expense
    if @billing_expense.save
      redirect_to @volunteer, make_notice
    else
      redirect_to @volunteer, notice: t('already_computed')
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

  def set_volunteer_hours
    @volunteer_hours = @volunteer.hours.where(billing_expense: nil)
  end

  def compute_hours
    return if @volunteer_hours.empty?
    hours = @volunteer_hours.sum(&:hours)
    minutes = @volunteer_hours.sum(&:minutes)
    hours += minutes / 60
    compute_amount(hours)
  end

  def compute_amount(hours)
    if hours < 25
      50
    elsif hours < 50
      100
    else
      150
    end
  end

  def volunteer_hours_update
    @volunteer_hours.update(billing_expense_id: @billing_expense.id)
  end

  def billing_expense_params
    params.require(:billing_expense).permit(:amount, :bank, :iban, :state, :volunteer_id)
  end
end
