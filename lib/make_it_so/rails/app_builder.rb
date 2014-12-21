require 'rails/generators/rails/app/app_generator'

module MakeItSo
  module Rails
    class AppBuilder < ::Rails::AppBuilder
      def rspec_dependency
        self.gem 'rspec-rails', group: [:development, :test]
        self.gem 'capybara', group: [:development, :test]
        self.gem 'launchy', group: [:development, :test]

        after_bundle do
          #stop spring in case it is running - it will hang
          #https://github.com/rails/rails/issues/13381
          run 'spring stop'
          generate 'rspec:install'
          inside 'spec' do
            empty_directory 'support'
          end

          inside 'spec' do
            insert_into_file 'rails_helper.rb',
              after: rails_helper_insertion_hook do

              "require 'capybara/rspec'\n"
            end
          end
        end
      end

      def factory_girl_rspec
        self.gem 'factory_girl', group: [:development, :test]
        after_bundle do
          inside 'spec' do
            insert_into_file 'rails_helper.rb',
              after: rails_helper_insertion_hook do

              "require File.join(File.dirname(__FILE__), 'support/factory_girl')\n"
            end

            inside 'support' do
              template 'factory_girl.rb'
            end
          end
        end
      end

      def valid_attribute_rspec
        self.gem 'valid_attribute', group: [:development, :test]
        after_bundle do
          inside 'spec' do
            insert_into_file 'rails_helper.rb',
              after: rails_helper_insertion_hook do

              "require File.join(File.dirname(__FILE__), 'support/valid_attribute')\n"
            end
          end
        end
      end

      protected
      def rails_helper_insertion_hook
        "require 'rspec/rails'\n"
      end
    end
  end
end
