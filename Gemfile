source 'https://rubygems.org'

gem 'aws-sdk'
gem 'config'
gem 'highline', '~> 1.7', '>= 1.7.8'

group :development do
  gem 'pry'
  gem 'pry-doc'
  gem 'yard'
end

# Do not place the capistrano-related gems in the default or Rails.env bundle group
# Otherwise the config/application.rb's Bundle.require command will try to load them
# leading to failure because these gem's rake task files use capistrano DSL.
group :deployment do
  # Use Capistrano for deployment
  gem 'capistrano', '> 3.1'
  gem 'capistrano-bundle_audit'
  gem 'capistrano-bundler', '> 1.1'
end
