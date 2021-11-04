source 'https://rubygems.org'

require_relative 'lib/make_it_so/rails'

ruby '3.0.2'

# Specify your gem's dependencies in make_it_so.gemspec
gemspec

group :development do
  gem 'pry'
  gem 'solargraph'

  [
    'rails',
    'activejob',
    'actionmailer'
  ].each do |gem_name|
    gem gem_name, MakeItSo::Rails::VERSION
  end

  gem 'sprockets-rails', '3.2.2'
  gem 'listen'
  gem 'rspec-rails'
  gem 'devise'
  gem 'webpacker'
end
