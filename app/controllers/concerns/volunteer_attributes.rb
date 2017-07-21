module VolunteerAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [
        :birth_year, :gender, :avatar, :nationality, :additional_nationality,
        :profession, :education, :motivation, :experience, :expectations,
        :strengths, :skills, :interests, :state, :duration, :man, :woman,
        :family, :kid, :sport, :creative, :music, :culture, :training,
        :german_course, :adults, :teenagers, :children, :region, :state,
        :working_percent, :volunteer_experience_desc, :region_specific,
        contact_attributes, language_skills_attributes, schedules_attributes
      ]
    end
  end
end
