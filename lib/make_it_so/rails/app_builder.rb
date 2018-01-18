require 'rails/generators/rails/app/app_generator'
require 'json'

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

      def pry_rails_dependency
        self.gem 'pry-rails', group: [:development, :test]
      end

      def fix_generators
        inject_into_class 'config/application.rb', 'Application' do
          snippet('application_generator.rb')
        end
      end

      def eliminate_byebug
        both_lines = /^[[:space:]]*# Call 'byebug'.*gem 'byebug'.*?$\n/m
        gsub_file 'Gemfile', both_lines, "\n"
      end

      def react
        self.gem 'webpacker', '~> 3.2'

        after_bundle do
          rake 'webpacker:install'
          rake 'webpacker:install:react'

          unparsed_json = snippet('react_dependencies.json')
          parsed_json = JSON.parse(unparsed_json)

          modify_json(package_json_file) do |json|
            ["dependencies"].each do |key|
              json[key] ||= {}
              json[key].merge!(parsed_json[key])
            end

            json["scripts"] ||= {}
            json["scripts"]["start"] = "./bin/webpack-dev-server"
          end

          rake 'yarn:install'
        end
      end

      def karma
        after_bundle do
          unparsed_json = snippet('js_testing_deps.json')
          parsed_json = JSON.parse(unparsed_json)

          modify_json(package_json_file) do |json|
            json["devDependencies"] ||= {}
            json["devDependencies"].merge!(parsed_json["devDependencies"])
            json["scripts"] ||= {}
            json["scripts"]["test"] = "node_modules/.bin/karma start karma.conf.js"
          end

          template 'karma.conf.js'
          inside 'spec/javascript' do
            template 'exampleTest.js'
            template 'testHelper.js'
          end

          rake 'yarn:install'
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

      def factory_bot_rspec
        self.gem 'factory_bot', group: [:development, :test]
        after_bundle do
          inside 'spec' do
            uncomment_lines 'rails_helper.rb', /spec\/support\/\*\*\/\*.rb/

            inside 'support' do
              template 'factory_bot.rb'
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
                insert_into_file 'factory_bot.rb',
                  after: "FactoryBot.define do\n" do

                  snippet('user_factory.rb')
                end
              end
            end
          end

          route "root 'homes\#index'"
        end
      end

      def foundation_dependency
        self.gem 'foundation-rails', '~> 5.0'

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
      PACKAGE_PATH = 'package.json'
      WEBCONFIG_PATH = 'webpack.config.js'

      protected
      def parsed_package_json
        @package_json ||= parse_json_file(package_json_file)
      end

      def package_json_file
        File.join(destination_root, PACKAGE_PATH)
      end

      def modify_json(file, &block)
        json = parse_json_file(file)
        block.call(json)
        File.write(file, JSON.pretty_generate(json))
      end

      def parse_json_file(file)
        contents = File.read(file)
        JSON.parse(contents)
      end

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
