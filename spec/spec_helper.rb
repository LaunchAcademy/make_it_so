require 'bundler/setup'
require 'rspec'
require 'capybara/rspec'

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '../lib/make_it_so')

require File.join(File.dirname(__FILE__), 'support/make_it_so_spec_helpers')
