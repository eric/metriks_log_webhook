source :rubygems

gem 'sinatra',   '~> 1.0'
gem 'yajl-ruby', '~> 0.7.8'
gem 'faraday'
gem 'faraday_middleware'
gem 'memcached'
gem 'activesupport', '~> 2.3', :require => 'active_support'
gem 'always_verify_ssl_certificates'

group :production do
  gem 'pg'

  # Use unicorn as the web server
  gem 'unicorn'
end

group :test do
  gem 'rack-test'
  gem 'turn', '0.8.2'
  gem 'mocha', :require => false
end