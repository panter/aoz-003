source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.0.rc1'

gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'devise'
gem 'jbuilder'
gem 'jquery-rails'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'sass-rails', github: 'rails/sass-rails'
gem 'simple_form'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'panter-rails-deploy'

group :development, :test do
  gem 'erb2haml'
  gem 'haml2slim'
  gem 'better_errors'
  gem 'binding_of_callers'
  gem 'capybara'
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
  gem 'spring'
end
