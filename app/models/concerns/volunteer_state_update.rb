module VolunteerStateUpdate
  extend ActiveSupport::Concern

  included do
    before_save :update_volunteer_state, if: :state_relevant_change?

    def state_relevant_change?
      will_save_change_to_attribute?(:period_start) || will_save_change_to_attribute?(:period_end)
    end

    def update_volunteer_state
      volunteer.verify_and_update_state
    end
  end
end
