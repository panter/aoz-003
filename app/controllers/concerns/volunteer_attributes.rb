module VolunteerAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [
        :birth_year, :salutation, :avatar, :nationality, :additional_nationality,
        :profession, :education, :motivation, :experience, :expectations, :strengths,
        :skills, :interests, :man, :woman, :family, :kid, :sport, :creative,
        :music, :culture, :training, :german_course, :teenagers, :children,
        :working_percent, :volunteer_experience_desc, :dancing, :health, :cooking,
        :excursions, :women, :unaccompanied, :zurich, :other_offer, :other_offer_desc,
        :trial_period, :doc_sent, :bank_account, :evaluation, :own_kids, :rejection_type,
        :rejection_text, :intro_course, :flexible, :morning, :afternoon, :evening,
        :workday, :weekend, :detailed_description, contact_attributes,
        language_skills_attributes, availability_attributes, group_offer_category_ids: []
      ]
    end
  end
end
