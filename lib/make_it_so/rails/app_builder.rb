require 'rails/generators/rails/app/app_generator'

module MakeItSo
  module Rails
    class AppBuilder < ::Rails::AppBuilder
      def rspec_dependency
        self.gem 'rspec-rails', group: [:development, :test]
        after_bundle do
          #stop spring in case it is running - it will hang
          #https://github.com/rails/rails/issues/13381
          run 'spring stop'
          generate 'rspec:install'
          inside 'spec' do
            empty_directory 'support'
          end
        end
      end

      def factory_girl_rspec
        self.gem 'factory_girl', group: [:development, :test]
        after_bundle do
          inside 'spec' do
            insert_into_file 'rails_helper.rb',
              after: "require 'rspec/rails'\n" do

              "require File.join(File.dirname(__FILE__), 'support/factory_girl')"
            end

            inside 'support' do
              template 'factory_girl.rb'
            end
          end
        end
      end
    end
  end
end
