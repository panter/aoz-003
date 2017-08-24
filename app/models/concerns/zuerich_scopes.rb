module ZuerichScopes
  extend ActiveSupport::Concern

  included do
    def self.zuerich_zips
      (8000..8099).to_a.map(&:to_s)
    end

    scope :zurich, (-> { joins(:contact).where(contacts: { postal_code: zuerich_zips }).distinct })
    scope :not_zurich, lambda {
      joins(:contact).where.not(contacts: { postal_code: zuerich_zips }).distinct
    }
  end
end
