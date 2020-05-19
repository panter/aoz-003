module AcceptanceAttributes
  extend ActiveSupport::Concern

  included do
    before_save :record_acceptance_change

    ransacker :acceptance, formatter: ->(value) { acceptances[value] }

    def acceptances_at_list(with_submittor: false)
      slice_keys = %i[invited_at accepted_at undecided_at rejected_at resigned_at]
      slice_keys += %i[created_at] if undecided_at.blank?
      slice(*slice_keys).compact.to_a.sort_by(&:last).map do |key, datetime|
        {
          attribute: self.class.human_attribute_name(key),
          datetime: datetime,
          user: public_send("#{key.remove('_at')}_by".to_sym)
        }
      end
    end
  end

  class_methods do
    def acceptance_collection
      acceptances.keys.map(&:to_sym)
    end

    def acceptance_filters
      acceptances.keys.map do |key|
        {
          q: :acceptance_eq,
          value: key,
          text: human_attribute_name(key)
        }
      end
    end
  end

  private

  def record_acceptance_change
    return unless new_record? || will_save_change_to_attribute?(:acceptance)

    # reactivated volunteers shouldn't look resigned, because having resigned_at date
    if will_save_change_to_attribute?(:acceptance, from: 'resigned', to: 'accepted')
      self.resigned_at = nil
    end
    self["#{acceptance}_at".to_sym] = Time.zone.now
  end
end
