class BillingExpensesController < ApplicationController
  before_action :set_billing_expense, only: [:show, :destroy]
  before_action :set_volunteer, only: [:index]
  before_action :set_selection, only: [:index, :download]
  before_action :set_periods, only: [:index]

  def index
    authorize BillingExpense

    set_default_filter(period: @billing_periods.first[:value])
    @q = policy_scope(BillingExpense).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?

    @billing_expenses = @q.result
    @billing_expenses = @billing_expenses.where(volunteer_id: @volunteer.id) if @volunteer
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
      html = render_to_string(action: 'show.html', layout: 'pdf.pdf')
      merged_expenses << CombinePDF.parse(WickedPdf.new.pdf_from_string(html, encoding: 'UTF-8'))
    end

    send_data merged_expenses.to_pdf,
      disposition: 'inline',
      filename: "Spesenauszahlungen-#{Time.zone.now.strftime '%F'}.pdf"
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: pdf_file_name, layout: 'pdf.pdf',
        template: 'billing_expenses/show.html.slim', encoding: 'UTF-8'
      end
    end
  end

  def new
    @billing_expense = BillingExpense.new
    authorize @billing_expense

    @q = Volunteer.with_billable_hours.ransack(params[:q])
    @volunteers = @q.result
    @selected_volunteers = params[:selected_volunteers].presence || []
  end

  def create
    authorize BillingExpense, :create?

    selected_volunteers = params[:selected_volunteers]
    volunteers = Volunteer.need_refunds.where(id: selected_volunteers)
    BillingExpense.create_for!(volunteers, current_user)

    redirect_to billing_expenses_url,
      notice: 'Spesenformulare wurden erfolgreich erstellt.'
  rescue ActiveRecord::RecordInvalid => error
    redirect_to new_billing_expense_url(selected_volunteers: selected_volunteers),
      notice: error.message
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

  def set_volunteer
    if params[:volunteer_id]
      @volunteer = Volunteer.find(params[:volunteer_id])
      authorize @volunteer, :show?
    end
  end

  def set_selection
    @selected_billing_expenses = params[:selected_billing_expenses].presence || []
  end

  def set_periods
    @billing_periods = []
    hours = Hour.billed
    oldest_date = hours.minimum(:meeting_date) || Time.zone.now
    newest_date = hours.maximum(:meeting_date) || Time.zone.now

    start_of_year = newest_date.beginning_of_year
    date = start_of_year
    date += BillingExpense::PERIOD if newest_date >= start_of_year + BillingExpense::PERIOD

    until date < oldest_date - BillingExpense::PERIOD
      @billing_periods << {
        q: :period,
        value: date.strftime('%Y-%m-%d'),
        text: '%s - %s' % [
          I18n.l(date, format: '%e. %B %Y'),
          I18n.l(date + BillingExpense::PERIOD - 1.day, format: '%e. %B %Y')
        ]
      }

      date -= BillingExpense::PERIOD
    end
  end

  def pdf_file_name
    'Spesenauszahlung-' +
      [
        @billing_expense.volunteer.contact.full_name,
        @billing_expense.volunteer.hours.maximum(:meeting_date)
      ].join('-').parameterize
  end

  def billing_expense_params
    params.require(:billing_expense).permit(:amount, :bank, :iban, :state, :volunteer_id)
  end
end
