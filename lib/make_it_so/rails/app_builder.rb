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

      def application_record
        inside 'app/models' do
          template 'application_record.rb'
        end
      end

      def base_javascripts
        @generator.gem 'jquery-rails'
        inside 'app/assets/javascripts' do
          template 'application.js'
          jquery_files = "//= require jquery\n" +
            "//= require jquery_ujs\n"
          gsub_file 'application.js', "//= require rails-ujs\n", jquery_files
        end
      end

      def base_stylesheets
        inside 'app/assets/stylesheets' do
          template 'application.css'
        end
      end

      def pry_rails_dependency
        @generator.gem 'pry-rails', group: [:development, :test]
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
        @generator.gem 'webpacker', '~> 3.3'

        rake 'webpacker:install'
        rake 'webpacker:install:react'
        remove_file 'app/javascript/packs/application.js'
        remove_file 'app/javascript/packs/hello_react.jsx'

        unparsed_json = snippet('react_dependencies.json')
        parsed_json = JSON.parse(unparsed_json)

        modify_json(package_json_file) do |json|
          ["dependencies", "devDependencies"].each do |key|
            json[key] ||= {}
            json[key].merge!(parsed_json[key])
          end

          json["scripts"] ||= {}
          json["scripts"]["start"] = "./bin/webpack-dev-server"
        end

        inside 'app/javascript/packs' do
          copy_file 'new_application.js', 'application.js'
          remove_file 'new_application.js'
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
        end
      end

      def jest
        after_bundle do
          deps = [
            'jest',
            'babel-jest',
            'enzyme-adapter-react-15.4',
            'react-addons-test-utils',
            'jest-fetch-mock'
          ]
          run "yarn add #{deps.join(' ')} --dev"

          run 'mkdir -p spec/javascript/support'
          inside 'spec/javascript/support' do
            template 'enzyme.js'
            template 'jest-fetch-mock.js'
          end

          modify_json(package_json_file) do |json|
            json["scripts"] ||= {}
            json["scripts"]["test"] = "node_modules/.bin/jest"
            json["scripts"]["test:dev"] = "node_modules/.bin/jest --notify --watch"
            json["jest"] ||= {}
            json["jest"].merge!({
              "automock": false,
              "roots": [
                "spec/javascript"
              ],
              "moduleDirectories": [
                "node_modules",
                "app/javascript"
              ],
              "setupFiles": [
                "./spec/javascript/support/enzyme.js",
                "./spec/javascript/support/jest-fetch-mock.js"
              ]
            })
          end

          run 'touch .babelrc'
          modify_json(File.join(destination_root, '.babelrc')) do |json|
            json["env"] ||= {}
            json["env"]["test"] ||= {}
            json["env"]["test"].merge!({
              "env": {
                "test": {
                  "presets": ["react", "env"],
                }
              }
            })
          end
        end
      end

      def yarn_install
        run 'yarn install'
      end

      def dotenv
        @generator.gem 'dotenv-rails', group: [:development, :test]
        template '.env'
        template '.env.example'

        append_to_file '.gitignore' do
          ".env\n"
        end
      end

      def rspec_dependency
        @generator.gem 'rspec-rails', group: [:development, :test]
        @generator.gem 'capybara', group: [:development, :test]
        @generator.gem 'launchy', group: [:development, :test]

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
        @generator.gem 'factory_bot', group: [:development, :test]
        after_bundle do
          inside 'spec' do
            uncomment_lines 'rails_helper.rb', /spec\/support\/\*\*\/\*.rb/

            inside 'support' do
              template 'factory_bot.rb'
            end
          end
        end
      end

      def database_cleaner_rspec
        @generator.gem 'database_cleaner', group: [:development, :test]
        after_bundle do
          inside 'spec' do
            inside 'support' do
              template 'database_cleaner.rb'
            end
          end
        end
      end

      def valid_attribute_rspec
        @generator.gem 'valid_attribute', group: [:development, :test]
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
        @generator.gem 'shoulda-matchers',
          group: [:development, :test],
          require: false
        after_bundle do
          inside 'spec/support' do
            template 'shoulda.rb'
          end
        end
      end

      def devise_dependency
        @generator.gem 'devise'

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

                template 'devise_controller_spec.rb'
              end
            end
          end

          route "root 'homes\#index'"
        end
      end

      def foundation_dependency
        @generator.gem 'foundation-rails', '~> 5.0'

        after_bundle do
          generate 'foundation:install foundation'
          # foundation-rails generates an application layout so we
          # must remove it
          # there is a pull request open to skip this:
          # https://github.com/zurb/foundation-rails/pull/108
          remove_file 'app/views/layouts/foundation.html.erb'

          inside 'app/assets/javascripts' do
            insert_into_file 'application.js',
              "//= require foundation\n",
              after: "//= require jquery_ujs\n"
          end
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
