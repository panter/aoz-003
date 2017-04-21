source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.0.rc1'

gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'devise'
gem 'devise_invitable'
gem 'gettext_i18n_rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'panter-rails-deploy'
gem 'paperclip'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'sass-rails', github: 'rails/sass-rails'
gem 'simple_form'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_callers'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'listen'
  gem 'overcommit', require: false
  gem 'poltergeist'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop', require: false
  gem 'selenium-webdriver'
end

group :development do
  gem 'gettext', require: false
  gem 'ruby_parser', require: false
  gem 'spring'
end
