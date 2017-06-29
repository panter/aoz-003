module VolunteerAttributes
  extend ActiveSupport::Concern

  included do
    include ContactAttributes
    def volunteer_attributes
      [
        :date_of_birth, :gender, :avatar, :nationality, :additional_nationality,
        :profession, :education, :motivation, :experience, :expectations,
        :strengths, :skills, :interests, :state, :duration, :man, :woman,
        :family, :kid, :sport, :creative, :music, :culture, :training,
        :german_course, :adults, :teenagers, :children, :region, :state,
        :first_language, :title, :first_name, :last_name,
        contact_attributes, language_skills_attributes, schedules_attributes
      ]
    end
  end
end
