module VolunteersGroupAndTandemStateUpdate
  extend ActiveSupport::Concern

  included do
    after_save :update_volunteer_state, if: :state_relevant_change?

    def ended?
      period_end.present? && period_end < Time.zone.today
    end

    def will_end?
      period_end.present? && period_end > Time.zone.today
    end

    def started?
      period_start.present? && period_start <= Time.zone.today
    end

    def will_start?
      period_start.present? && period_start > Time.zone.today
    end

    def active?
      started? && !ended?
    end

    def inactive?
      period_start.blank? || ended? || will_start?
    end

    def state_relevant_change?
      saved_change_to_period_start? || saved_change_to_period_end?
    end

    def update_volunteer_state
      volunteer.verify_and_update_state
    end
  end
end
