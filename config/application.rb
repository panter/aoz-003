require_relative 'boot'

ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'webdrivers/chromedriver'
require 'active_storage/engine'
Webdrivers.install_dir = '.ci-cache/webdrivers'

module Aoz
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.time_zone = 'Zurich'
    config.autoload_paths += Dir[config.root.join('lib/access_import/**/')]
    config.autoload_paths += Dir[config.root.join('lib/access_import/accessors/**/')]
    WillPaginate.per_page = 20
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
