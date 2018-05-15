module VolunteerAttributes
  extend ActiveSupport::Concern

  included do
    def volunteer_attributes
      [
        :birth_year, :salutation, :avatar, :nationality, :additional_nationality,
        :profession, :education, :motivation, :experience, :expectations, :strengths,
        :skills, :interests, :man, :woman, :family, :kid, :teenager, :unaccompanied, :other_offer_desc,
        :trial_period, :doc_sent, :bank_account, :evaluation, :own_kids, :rejection_type,
        :rejection_text, :intro_course, :flexible, :morning, :afternoon, :evening, :working_percent,
        :workday, :weekend, :detailed_description, :volunteer_experience_desc,
        contact_attributes, language_skills_attributes, availability_attributes,
        group_offer_category_ids: []
      ]
    end
  end
end
