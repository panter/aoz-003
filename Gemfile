source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1'

gem 'autoprefixer-rails'
gem 'axlsx', '~> 2.1.0.pre' # Requirement for axlsx to run with actual rails version
gem 'axlsx_rails'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-sass'
gem 'cocoon'
gem 'coffee-rails'
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
gem 'paperclip'
gem 'paranoia'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rails-i18n'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'redcarpet'
gem 'rubyzip'
gem 'sass-rails'
gem 'simple_form'
gem 'slim-rails'
gem 'sprockets-es6'
gem 'turbolinks'
gem 'uglifier'
gem 'whenever', require: false
gem 'wicked_pdf'
gem 'will-paginate-i18n'
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap'
gem 'wkhtmltopdf-binary'

group :production, :development do
  gem 'mdb'
  gem 'panter-rails-deploy'
end

group :development, :test do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_callers'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'i18n_yaml_sorter'
  gem 'listen'
  gem 'overcommit', require: false
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'policy-assertions'
  gem 'poltergeist'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop', require: false
  gem 'scss_lint', require: false
  gem 'selenium-webdriver'
  gem 'spring'
end

group :test do
  gem 'roo', '~> 2.7.0'
end
