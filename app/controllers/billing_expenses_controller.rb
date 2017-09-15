class BillingExpensesController < ApplicationController
  before_action :set_billing_expense, only: [:show, :destroy]
  before_action :set_volunteer

  def index
    authorize BillingExpense
    @billing_expenses = BillingExpense.where(volunteer: @volunteer)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: file_name, layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end

  def new
    @billing_expense = BillingExpense.new(volunteer: @volunteer)
    authorize @billing_expense
  end

  def create
    @billing_expense = BillingExpense.new(
      billing_expense_params.merge(@volunteer.slice(:bank, :iban))
    )
    @billing_expense.hours = @volunteer.hours.billable
    @billing_expense.user = current_user
    authorize @billing_expense
    if @billing_expense.save
      redirect_to volunteer_billing_expenses_url, make_notice
    else
      redirect_to volunteer_billing_expenses_url, notice: t('already_computed')
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

  def file_name
    [@volunteer.contact.full_name, @volunteer.hours.maximum(:meeting_date)].join('-').parameterize
  end

  def billing_expense_params
    params.require(:billing_expense).permit(:amount, :bank, :iban, :state, :volunteer_id)
  end
end
