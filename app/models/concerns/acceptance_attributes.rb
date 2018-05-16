module AcceptanceAttributes
  extend ActiveSupport::Concern

  included do
    before_save :record_acceptance_change

    ransacker :acceptance, formatter: ->(value) { acceptances[value] }
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
    return unless new_record? || will_save_change_to_acceptance?

    self["#{acceptance}_at".to_sym] = Time.zone.now
  end
end
