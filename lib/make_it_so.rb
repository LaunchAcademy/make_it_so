require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

module MakeItSo
  def self.source_root(template_category = nil)
    root = File.join(File.dirname(__FILE__), '../templates')
    template_category.nil? ? root : File.join(root, template_category.to_s)
  end
end

require "make_it_so/version"

require "make_it_so/rails"

require "make_it_so/command_line_interface"
require "generators/rails_app_generator"
require "generators/sinatra_app_generator"
require "generators/gosu_app_generator"
