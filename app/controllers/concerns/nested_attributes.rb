module NestedAttributes
  extend ActiveSupport::Concern

  included do
    def language_skills_attributes
      {
        language_skills_attributes: [:id, :language, :level, :_destroy]
      }
    end

    def relatives_attributes
      {
        relatives_attributes: [:id, :first_name, :last_name, :birth_year, :relation, :_destroy]
      }
    end
  end
end
