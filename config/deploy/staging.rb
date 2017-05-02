server 'aoz-003-staging.panter.biz', roles: %w[web app db]
set :branch, 'develop'
set :ssh_options, keys: ['config/deploy_id_rsa'] if File.exist?('config/deploy_id_rsa')
