source 'https://rubygems.org'
ruby '2.6.6'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '>= 6.0.0', '< 6.1.0'

gem 'active_storage_validations'
gem 'bootsnap', require: false
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-sass'
gem 'bootstrap-will_paginate'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'cocoon'
gem 'coffee-rails'
gem 'combine_pdf'
gem 'countries'
gem 'countries_and_languages', require: 'countries_and_languages/rails'
gem 'country_select'
gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable'
gem 'factory_bot_rails'
gem 'ffaker'
gem 'google-cloud-storage', '~> 1.11', require: false
gem 'i18n_data'
gem 'i18n_rails_helpers'
gem 'image_processing'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'js-routes'
gem 'lodash-rails'
gem 'net-sftp'
gem 'panter-rails-deploy'
gem 'paperclip'
gem 'paranoia'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rails-i18n'
gem 'ransack'
gem 'redcarpet'
gem 'rubyzip', '>= 1.2.2'
gem 'sassc-rails'
gem 'selectize-rails'
gem 'simple_form'
gem 'slim-rails'
gem 'sprockets-es6'
gem 'uglifier'
gem 'webdrivers', '~> 4.0'
gem 'webpacker'
gem 'wicked_pdf'
gem 'will_paginate'
gem 'will-paginate-i18n'
gem 'wkhtmltopdf-heroku'

group :development do
  gem 'debase', require: false
  gem 'debride', require: false
  gem 'fasterer', require: false
  gem 'i18n_yaml_sorter'
  gem 'letter_opener_web'
  gem 'overcommit', require: false
  gem 'rcodetools', require: false
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'ruby-debug-ide', require: false
  gem 'ruby-lint', require: false
  gem 'wkhtmltopdf-binary'
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_callers'
  gem 'hirb'
  gem 'hirb-unicode-steakknife', require: 'hirb-unicode'
  gem 'listen'
  gem 'pdf-reader'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'spring'
end

group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'database_cleaner'
  gem 'minitest'
  gem 'policy-assertions'
  gem 'roo'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
end
