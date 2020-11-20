class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  acts_as_paranoid

  scope :field_nil, ->(field) { where(field.to_sym => nil) }
  scope :field_not_nil, ->(field) { where.not(field.to_sym => nil) }

  scope :date_before, ->(field, date) { where("#{table_name}.#{field} < ?", date) }
  scope :date_at_or_before, ->(field, date) { where("#{table_name}.#{field} <= ?", date) }
  scope :date_after, ->(field, date) { where("#{table_name}.#{field} > ?", date) }
  scope :date_at_or_after, ->(field, date) { where("#{table_name}.#{field} >= ?", date) }

  scope :date_between, lambda { |field, start_date, end_date|
    date_before(field, end_date).date_after(field, start_date)
  }

  scope :date_between_inclusion, lambda { |field, start_date, end_date|
    start_date, end_date = end_date, start_date if start_date < end_date
    where("#{table_name}.#{field} BETWEEN ? AND ?", end_date, start_date)
  }

  scope :date_between_inc_start, lambda { |field, start_date, end_date|
    date_before(field, end_date).date_at_or_after(field, start_date)
  }

  scope :date_between_inc_end, lambda { |field, start_date, end_date|
    date_at_or_before(field, end_date).date_after(field, start_date)
  }

  scope :created_before, ->(max_time) { date_before(:created_at, max_time) }
  scope :created_at_or_before, ->(max_time) { date_at_or_before(:created_at, max_time) }
  scope :created_after, ->(min_time) { date_after(:created_at, min_time) }
  scope :created_at_or_after, ->(min_time) { date_at_or_after(:created_at, min_time) }
  scope :created_between, lambda { |start_date, end_date|
    date_between(:created_at, start_date, end_date)
  }

  scope :updated_before, ->(max_time) { date_before(:updated_at, max_time) }
  scope :updated_after, ->(min_time) { date_after(:updated_at, min_time) }
  scope :updated_between, lambda { |start_date, end_date|
    date_between(:updated_at, start_date, end_date)
  }

  # order scopes
  scope :created_desc, (-> { order("#{table_name}.created_at DESC") })
  scope :created_asc, (-> { order("#{table_name}.created_at ASC") })
  scope :updated_desc, (-> { order("#{table_name}.updated_at DESC") })
  scope :updated_asc, (-> { order("#{table_name}.updated_at ASC") })

  scope :polymorph_model, ->(model) { where("#{model_name}able_type = ?", model.to_s.classify) }

  # translate enum fields value
  def t_enum(enum_field)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}."\
      "#{enum_field.to_s.pluralize}.#{public_send(enum_field)}")
  end

  # simple form translation 'simple_form.options.model_name.enum_field.key'
  def self.enum_collection(enum_field)
    public_send(enum_field.to_s.pluralize).keys.map(&:to_sym)
  end

  def self.ext_mimes(*extensions)
    extensions.flat_map do |ext|
      MIME::Types.select { |type| type.extensions.include?(ext.to_s) }
    end.map(&:to_s)
  end
end
