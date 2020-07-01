class BillingExpensesController < ApplicationController
  before_action :set_billing_expense, only: [:show, :update_overwritten_amount, :destroy]
  before_action :set_billing_semesters, only: [:new, :create]
  before_action :set_selection, only: [:index, :download]

  def index
    authorize BillingExpense
    @billing_semester_filters = BillingExpense.generate_semester_filters(:billed)
    set_default_filter(semester: default_billing_semester)
    @q = policy_scope(BillingExpense).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @billing_expenses = @q.result

    if params[:volunteer_id]
      @volunteer = Volunteer.find(params[:volunteer_id])
      authorize @volunteer, :show?

      @billing_expenses = @billing_expenses.where(volunteer: @volunteer)
    end
  end

  def download
    authorize BillingExpense

    if @selected_billing_expenses.blank?
      flash[:notice] = 'Bitte wählen Sie die Spesenformulare aus die Sie herunterladen möchten.'
      return redirect_back(fallback_location: billing_expenses_path)
    end

    merged_expenses = CombinePDF.new
    billing_expenses = policy_scope(BillingExpense).where(id: @selected_billing_expenses)

    billing_expenses.each do |billing_expense|
      @billing_expense = billing_expense
      merged_expenses << CombinePDF.parse(render_to_pdf('show.html', layout: WickedPdf.config[:layout]))
    end

    send_data merged_expenses.to_pdf,
      disposition: 'inline',
      filename: "Spesenauszahlungen-#{Time.zone.now.strftime '%F'}.pdf"
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: pdf_file_name(@billing_expense),
          template: 'billing_expenses/show.html'
      end
    end
  end

  def new
    @billing_expense = BillingExpense.new
    authorize @billing_expense

    @volunteers_with_hours = Volunteer.with_billable_hours(selected_billing_semester)
    @selected_volunteers = params[:selected_volunteers].presence || []
  end

  def create
    authorize BillingExpense, :create?

    selected_volunteers = params[:selected_volunteers]
    selected_semester = params[:selected_semester]
    volunteers = Volunteer.need_refunds.where(id: selected_volunteers)
    BillingExpense.create_for!(volunteers, current_user, selected_semester)

    redirect_to billing_expenses_url,
      notice: 'Spesenformulare wurden erfolgreich erstellt.'
  rescue ActiveRecord::RecordInvalid => error
    redirect_to new_billing_expense_url(selected_volunteers: selected_volunteers),
      notice: error.message
  end

  def update_overwritten_amount
    overwritten_amount = params[:billing_expense][:overwritten_amount]
    @billing_expense.update_attribute(:overwritten_amount, overwritten_amount)
  end

  def destroy
    @billing_expense.destroy
    redirect_to billing_expenses_url, make_notice
  end

  private

  def set_billing_expense
    @billing_expense = BillingExpense.find(params[:id])
    authorize @billing_expense
  end

  def set_billing_semesters
    @billing_semester_filters = BillingExpense.semester_back_filters
  end

  def set_selection
    @selected_billing_expenses = params[:selected_billing_expenses].presence || []
  end

  def default_billing_semester
    @billing_semester_filters.first[:value]
  end

  def selected_billing_semester
    @selected_billing_semester = if params[:q].blank?
      set_default_filter(semester: default_billing_semester)
      default_billing_semester
    elsif !@billing_semester_filters.pluck(:value).include? params[:q][:semester]
      params.permit![:q][:semester] = default_billing_semester
      default_billing_semester
    else
      params[:q][:semester]
    end
  end

  def pdf_file_name(record)
    'Spesenauszahlung-' +
      [
        record.volunteer.contact.full_name,
        record.hours.maximum(:meeting_date)
      ].join('-').parameterize
  end

  def billing_expense_params
    params.require(:billing_expense).permit(:amount, :bank, :iban, :state, :volunteer_id)
  end
end
