# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{yml}')]

# Available locales
I18n.available_locales = [:en, :de]

I18n.default_locale = ENV['RAILS_LANGUAGE'].present? ? ENV['RAILS_LANGUAGE'].to_sym : :en
