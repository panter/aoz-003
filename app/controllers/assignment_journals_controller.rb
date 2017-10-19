class AssignmentJournalsController < ApplicationController
  before_action :set_assignment_journal, only: [:show, :edit, :update, :destroy]
  before_action :set_assignment

  def index
    authorize AssignmentJournal
    @assignment_journals = policy_scope(AssignmentJournal).where(assignment: @assignment)
  end

  def show; end

  def new
    @assignment_journal = AssignmentJournal.new(assignment: @assignment,
      volunteer: @assignment.volunteer)
    authorize @assignment_journal
  end

  def edit; end

  def create
    @assignment_journal = AssignmentJournal.new(assignment_journal_params
      .merge(author_id: current_user.id))
    authorize @assignment_journal
    if @assignment_journal.save
      redirect_to assignment_assignment_journal_path(@assignment, @assignment_journal), make_notice
    else
      render :new
    end
  end

  def update
    if @assignment_journal.update(assignment_journal_params)
      redirect_to assignment_assignment_journal_path(@assignment, @assignment_journal), make_notice
    else
      render :edit
    end
  end

  def destroy
    @assignment_journal.destroy
    redirect_to assignment_assignment_journals_path, make_notice
  end

  private

  def set_assignment_journal
    @assignment_journal = AssignmentJournal.find(params[:id])
    authorize @assignment_journal
  end

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end

  def assignment_journal_params
    params.require(:assignment_journal).permit(:goals, :achievements, :future, :comments,
      :conversation, :assignment_id, :volunteer_id)
  end
end