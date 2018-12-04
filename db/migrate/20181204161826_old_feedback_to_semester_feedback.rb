class OldFeedbackToSemesterFeedback < ActiveRecord::Migration[5.1]
  def change
    Feedback.find_each do |f|
      spv = SemesterProcessVolunteer.create(
        volunteer: f.volunteer,
        commited_at: f.created_at,
        commited_by: f.author
      )

      missions = if f.feedbackable.is_a? GroupOffer
              f.feedbackable.group_assignments.where(volunteer: f.volunteer)
            elsif f.feedbackable.is_a? Assignment
              [f.feedbackable]
            end
      
      missions.each do |mis|
        SemesterProcessVolunteerMission.create(
          mission: mis,
          semester_process_volunteer: spv
        )

        s = SemesterFeedback.create(
          f.slice(:goals, :achievements, :future, :comments, :conversation, :author).merge(
            semester_process_volunteer: spv,
            mission: mis
          )
        )
      end
    end
  end
end
