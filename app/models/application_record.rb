class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  acts_as_paranoid

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
