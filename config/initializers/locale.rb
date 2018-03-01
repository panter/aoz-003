# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{yml}')]

# Available locales
I18n.available_locales = [:de]
I18n.default_locale = :de
