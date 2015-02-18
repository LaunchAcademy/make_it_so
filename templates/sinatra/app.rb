require 'sinatra'
require 'sinatra/reloader'

configure :development, :test do
  require 'pry'
end

Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each do |file|
  require file
  also_reload file
end

get '/' do
  @title = "Hello World"
  erb :index
end
