class ReviewSemestersController < ApplicationController
  before_action :prepare_review, :initialize_nested_objects, only: [:review_semester, :submit_review]

  def review_semester; end

  def submit_review
    # you shall not pass
    return if @semester_process_volunteer.commited_at

    set_reviewed
    assign_volunteer_attributes
    build_nested_objects

    if save_feedback_data!
      create_journals
      redirect_to review_semester_review_semester_url(@semester_process_volunteer), notice: t('.success')
    else
      render :review_semester
    end
  end

  private

  def save_feedback_data!
    @semester_process_volunteer.volunteer.validate_waive_and_bank = true

    ActiveRecord::Base.transaction do
      @semester_process_volunteer.save!
      @volunteer.save!

      @nested_objects.each do |_key, hash|
        hash.each { |_id, obj| obj.save! }
      end
    end
    # reload the variable
    @semester_process_volunteer.reload
    true
  rescue ActiveRecord::RecordInvalid => exception
    null_reviewed
    flash[:alert] = exception.message
    false
  end

  def create_journals
    spv = @semester_process_volunteer
    return unless spv.commited_at?

    volunteer = spv.volunteer
    semester_feedbacks = spv.semester_feedbacks
    author = current_user.volunteer? ? @semester_process_volunteer.semester_process.creator : current_user
    Journal.create(user: author, journalable: volunteer,
      category: :feedback, title: "Semester Prozess Feedback vom #{I18n.l(Time.zone.today)}: ",
      body: render_semester_feedbacks(semester_feedbacks))
  end

  def null_reviewed
    @semester_process_volunteer.commited_by = nil
    @semester_process_volunteer.commited_at = nil
  end

  def assign_volunteer_attributes
    @volunteer.assign_attributes(review_params[:volunteer_attributes]
      .slice(:waive, :bank, :iban))
  end

  def set_reviewed
    @semester_process_volunteer.commited_by = current_user
    @semester_process_volunteer.commited_at = Time.zone.now
  end

  def build_nested_objects
    review_params[:semester_feedbacks_attributes].each do |_key, hash|
      spv_mission = SemesterProcessVolunteerMission.find(hash[:semester_feedback][:spv_mission_id])
      @nested_objects[spv_mission.id.to_s][:feedback] = SemesterFeedback.new(hash[:semester_feedback].merge({
        author: current_user, semester_process_volunteer: @semester_process_volunteer
      }))

      if hash[:hour][:hours].to_i.positive?
        @nested_objects[spv_mission.id.to_s][:hours] = Hour.new(hash[:hour].merge({
          volunteer: spv_mission.volunteer,
          meeting_date: spv_mission.semester_process_volunteer.semester.last.to_date,
          hourable: spv_mission.mission.group_assignment? ? spv_mission.mission.group_offer : spv_mission.mission
        }))
      end
    end
  end

  def prepare_review
    @semester_process_volunteer = SemesterProcessVolunteer.find(params[:id])
    authorize @semester_process_volunteer
    @volunteer = @semester_process_volunteer.volunteer
    @missions = @semester_process_volunteer.missions
  end

  def initialize_nested_objects
    @nested_objects = {}
    @semester_process_volunteer.semester_process_volunteer_missions.need_feedback.each do |spvm|
      @nested_objects[spvm.id.to_s] = { feedback: @semester_process_volunteer.semester_feedback_with_mission(spvm.mission) || SemesterFeedback.new }
    end
    @nested_objects
  end

  def render_semester_feedbacks(semester_feedbacks)
    text = ''
    semester_feedbacks.each do |semester_feedback|
      text += semester_feedback.mission.to_label
      text += "\n\n"
      text += semester_feedback.slice(:goals, :achievements, :future, :comments).map do |key, sfb_quote|
        "#{I18n.t("activerecord.attributes.feedback.#{key}")}:\n«#{sfb_quote}»" if sfb_quote.present?
      end.compact.join("\n\n")
      text += "\n\n"
    end
    text
  end

  def review_params
    params.require(:semester_process_volunteer).permit(
      volunteer_attributes: [:id, :waive, :iban, :bank],
      semester_feedbacks_attributes: [[semester_feedback: [:mission, :goals, :achievements, :future, :comments, :conversation, :spv_mission_id]],
                                      [hour: [:hours, :spv_mission_id, :activity]]]
    )
  end
end
