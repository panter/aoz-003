module NestedAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [:date_of_birth, :gender, :avatar, :nationality, :additional_nationality,
       :profession, :education, :motivation, :experience, :expectations,
       :strengths, :skills, :interests, :state, :rejection_type, :rejection_text,
       :duration, :man, :woman, :family, :kid, :sport, :creative, :music, :culture,
       :training, :german_course, :adults, :teenagers, :children, :region]
    end

    def language_skills_attributes
      [:id, :language, :level, :_destroy]
    end

    def relatives_attributes
      [:id, :first_name, :last_name, :date_of_birth, :relation, :_destroy]
    end

    def schedules_attributes
      [:id, :day, :time, :available]
    end
  end
end
