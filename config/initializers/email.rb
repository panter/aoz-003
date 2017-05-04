if Rails.env.production?
  ActionMailer::Base.delivery_method = :sendmail

  ActionMailer::Base.default_url_options = {
    host: 'aoz-003-staging.panter.biz',
    protocol: 'https'
  }
else
  ActionMailer::Base.default_url_options = {
    host: 'localhost:3000'
  }
end
