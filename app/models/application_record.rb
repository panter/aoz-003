class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  acts_as_paranoid

  # order scopes
  scope :created_desc, (-> { order('created_at desc') })
  scope :created_asc, (-> { order('created_at asc') })
  scope :updated_desc, (-> { order('updated_at desc') })
  scope :updated_asc, (-> { order('updated_at asc') })

  scope :created_before, ->(max_time) { where("#{model_name.plural}.created_at < ?", max_time) }
  scope :created_after, ->(min_time) { where("#{model_name.plural}.created_at > ?", min_time) }
  scope :created_between, lambda { |start_date, end_date|
    created_after(start_date).created_before(end_date)
  }

  scope :updated_before, ->(max_time) { where("#{model_name.plural}.updated_at < ?", max_time) }
  scope :updated_after, ->(min_time) { where("#{model_name.plural}.updated_at > ?", min_time) }
  scope :updated_between, lambda { |start_date, end_date|
    updated_after(start_date).updated_before(end_date)
  }

  # translate enum fields value
  def t_enum(enum_field)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}."\
      "#{enum_field.to_s.pluralize}.#{public_send(enum_field)}")
  end

  # simple form translation 'simple_form.options.model_name.enum_field.key'
  def self.enum_collection(enum_field)
    public_send(enum_field.to_s.pluralize).keys.map(&:to_sym)
  end
end
