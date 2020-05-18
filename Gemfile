source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '>= 5.2.0', '< 6.0.0'

gem 'autocomplete_rails'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-sass'
gem 'bootstrap-will_paginate'
gem 'cocoon'
gem 'coffee-rails'
gem 'combine_pdf'
gem 'countries'
gem 'countries_and_languages', require: 'countries_and_languages/rails'
gem 'country_select'
gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable'
gem 'i18n_data'
gem 'i18n_rails_helpers'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'js-routes'
gem 'lodash-rails'
gem 'mdb'
gem 'panter-rails-deploy'
gem 'paperclip'
gem 'paranoia'
gem 'pg', '~> 0.21'
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
gem 'wicked_pdf'
gem 'will-paginate-i18n'
gem 'will_paginate'
gem 'wkhtmltopdf-binary'

group :development do
  gem 'awesome_print', require: false
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
  gem 'scss_lint', require: false
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_callers'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'listen'
  gem 'pdf-reader'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
end

group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'minitest'
  gem 'policy-assertions'
  gem 'roo'
  gem 'selenium-webdriver'
end
