source 'https://rubygems.org'

ruby '2.2.2'

gem 'rake'
gem 'dotenv'

gem 'sequel'
gem 'mysql2', platform: :ruby
gem 'pg', platform: :ruby
gem 'jdbc-mysql', platform: :jruby
gem 'jdbc-postgres', platform: :jruby

gem 'sinatra'
gem 'rack-flash3'
gem 'erubis'
gem 'macmillan-utils'

gem 'unicorn', require: false, platform: :ruby
gem 'puma', require: false

gem 'airbrake', require: false
gem 'statsd-ruby', require: false
gem 'newrelic_rpm'

group :development do
  gem 'shotgun'
  gem 'rubocop'
end

group :test do
  gem 'sqlite3', platform: :ruby
  gem 'jdbc-sqlite3', platform: :jruby
  gem 'rspec'
  gem 'rack-test'
  gem 'capybara'
  gem 'poltergeist'
  gem 'webmock'
  gem 'pry'
  gem 'guard-rspec', require: false
end
