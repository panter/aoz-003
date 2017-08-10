module VolunteerAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [
        :birth_year, :salutation, :avatar, :nationality, :additional_nationality,
        :profession, :education, :motivation, :experience, :expectations, :strengths,
        :skills, :interests, :state, :man, :woman, :family, :kid, :sport, :creative,
        :music, :culture, :training, :german_course, :teenagers, :children, :state,
        :working_percent, :volunteer_experience_desc, :dancing, :health, :cooking,
        :excursions, :women, :unaccompanied, :zurich, :other_offer, :other_offer_desc,
        :own_kids, contact_attributes, language_skills_attributes
      ]
    end
  end
end
