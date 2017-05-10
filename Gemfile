source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.0.rc1'

gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'cocoon'
gem 'coffee-rails'
gem 'countries'
gem 'countries_and_languages', require: 'countries_and_languages/rails'
gem 'country_select'
gem 'devise'
gem 'devise_invitable'
gem 'i18n_data'
gem 'i18n_rails_helpers'
gem 'jbuilder'
gem 'jquery-rails'
gem 'panter-rails-deploy'
gem 'paperclip'
gem 'paranoia', '~> 2.2'
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
  gem 'shoulda', '~> 3.5'
  gem 'shoulda-matchers', '~> 2.0'
end

group :development do
  gem 'spring'
end
