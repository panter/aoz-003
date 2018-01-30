module TerminationScopes
  extend ActiveSupport::Concern

  included do
    scope :termination_submitted, (-> { where("#{model_name.plural}.termination_submitted_by_id IS NOT NULL") })
    scope :termination_not_submitted, (-> { where("#{model_name.plural}.termination_submitted_by_id IS NULL") })
    scope :unterminated, (-> { where("#{model_name.plural}.termination_verified_by_id IS NULL") })
    scope :terminated, (-> { where("#{model_name.plural}.termination_verified_by_id IS NOT NULL") })
  end
end
