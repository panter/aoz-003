if Rails.env.production?
  ActionMailer::Base.default_url_options = {
    host: ENV['DEVISE_EMAIL_DOMAIN'] || 'staging.aoz-freiwillige.ch',
    protocol: 'https'
  }
else
  ActionMailer::Base.default_url_options = {
    host: 'localhost:3000'
  }
end
