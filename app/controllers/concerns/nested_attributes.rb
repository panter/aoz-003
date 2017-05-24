module NestedAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [:first_name, :last_name, :date_of_birth, :gender, :avatar, :street,
      :zip, :city, :nationality, :additional_nationality, :email, :phone,
      :profession, :education, :motivation, :experience, :expectations,
      :strengths, :skills, :interests, :state, :duration, :man, :woman,
      :family, :kid, :sport, :creative, :music, :culture, :training,
      :german_course, :adults, :teenagers, :children, :region]
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
