ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# FIXME:
#  - autoprefixer doesn't run with rubyracer anymore, it would with miniracer
#  - installing miniracer ist blocked by panter/panter-rails-deploy rubyracer requirement
#  - using Node as Execjs Runtime is not possible, because our hosts don't have node
# ENV['EXECJS_RUNTIME'] = 'Node'

require 'bundler/setup' # Set up gems listed in the Gemfile.
