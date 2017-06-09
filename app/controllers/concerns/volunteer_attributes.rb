module VolunteerAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [
        :date_of_birth, :gender, :avatar, :nationality, :additional_nationality,
        :profession, :education, :motivation, :experience, :expectations,
        :strengths, :skills, :interests, :state, :duration, :man, :woman,
        :family, :kid, :sport, :creative, :music, :culture, :training,
        :german_course, :adults, :teenagers, :children, :region, :state
      ]
    end
  end
end
