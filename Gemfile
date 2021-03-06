source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1'

gem 'autocomplete_rails'
gem 'autoprefixer-rails'
gem 'axlsx', github: 'randym/axlsx', ref: '776037c0fc799bb09da8c9ea47980bd3bf296874'
gem 'axlsx_rails'
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
gem 'font-awesome-sass'
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
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'redcarpet'
gem 'rubyzip', '>= 1.2.1'
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
  gem 'awesome_print'
  gem 'i18n_yaml_sorter'
  gem 'letter_opener'
  gem 'overcommit', require: false
  gem 'rubocop', require: false
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
  gem 'minitest', '~> 5.10.3'
  gem 'policy-assertions'
  gem 'roo', '~> 2.7.0'
  gem 'selenium-webdriver'
end
