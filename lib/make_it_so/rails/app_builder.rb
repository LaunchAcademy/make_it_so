require 'rails/generators/rails/app/app_generator'

module MakeItSo
  module Rails
    class AppBuilder < ::Rails::AppBuilder
      def application_controller
        inside 'app/controllers' do
          template 'application_controller.rb'
        end
      end

      def base_javascripts
        inside 'app/assets/javascripts' do
          template 'application.js'
        end
      end

      def base_stylesheets
        inside 'app/assets/stylesheets' do
          template 'application.css'
        end
      end

      def fix_generators
        inject_into_class 'config/application.rb', 'Application' do
          snippet('application_generator.rb')
        end
      end

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

            inside 'support' do
              template 'valid_attribute.rb'
            end
          end
        end
      end

      def shoulda_rspec
        self.gem 'shoulda-matchers',
          group: [:development, :test],
          require: false
        after_bundle do
          inside 'spec' do
            insert_into_file 'rails_helper.rb',
              after: rails_helper_insertion_hook do

               "require 'shoulda-matchers'\n"
            end
          end
        end
      end

      def teaspoon_jasmine
        self.gem 'teaspoon-jasmine'
        after_bundle do
          generate 'teaspoon:install'
        end
      end

      def devise_dependency
        self.gem 'devise'

        after_bundle do
          generate 'devise:install'
          generate 'devise:views'
          generate 'devise user'

          if options[:rspec]
            inside 'spec' do
              directory 'features'

              inside 'support' do
                insert_into_file 'factory_girl.rb',
                  after: "FactoryGirl.define do\n" do

                  snippet('user_factory.rb')
                end
              end
            end
          end

          route "root 'homes\#index'"
        end
      end

      def foundation_dependency
        self.gem 'foundation-rails'

        after_bundle do
          generate 'foundation:install foundation'
          # foundation-rails generates an application layout so we
          # must remove it
          # there is a pull request open to skip this:
          # https://github.com/zurb/foundation-rails/pull/108
          remove_file 'app/views/layouts/foundation.html.erb'
        end
      end

      protected
      def rails_helper_insertion_hook
        "require 'rspec/rails'\n"
      end

      def snippet_path
        File.join(File.dirname(__FILE__), '../../../snippets/rails')
      end

      def snippet(path)
        File.read(File.join(snippet_path, path))
      end
    end
  end
end
