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

      def change_ruby_version
        # @generator.gem 'pg', '3.8.2', group: [:development, :test]

        default_ruby_version = /^ruby '2.6.5'$/
        gsub_file 'Gemfile', default_ruby_version, "\n"
      end

      def react
        @generator.gem 'webpacker', '~> 3.3'

        after_bundle do
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

            json["dependencies"].delete("babel-preset-react")
          end

          inside 'app/javascript/packs' do
            copy_file 'new_application.js', 'application.js'
            remove_file 'new_application.js'
          end

        end
      end

      def karma
        after_bundle do
          add_test_dependency_snippets(
            ["js_karma_jasmine_testing_deps.json", "js_enzyme_testing_deps.json"]
          )

          create_enzyme_config

          template 'karma.conf.js'
          inside 'spec/javascript' do
            template 'exampleTest.js'
            template 'testHelper.js'
          end

          append_to_file '.gitignore' do
            "coverage/*\n"
          end

          remove_file '.babelrc'
          remove_file 'babel.config.js'
          template 'babel.config.js'
        end
      end

      def jest
        after_bundle do
          add_test_dependency_snippets(
            ["js_jest_testing_deps.json", "js_enzyme_testing_deps.json"]
          )

          create_enzyme_config

          remove_file '.babelrc'
          remove_file 'babel.config.js'
          template 'babel.config.js'
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
        @generator.gem 'rspec-rails', '3.8.2', group: [:development, :test]
        @generator.gem 'capybara', group: [:development, :test]
        @generator.gem 'launchy', group: [:development, :test]

        after_bundle do
          if !options[:skip_spring]
            #stop spring in case it is running - it will hang
            #https://github.com/rails/rails/issues/13381
            run 'spring stop'
          end
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
            insert_into_file 'rails_helper.rb',
              after: rails_helper_insertion_hook do

              "require File.join(File.dirname(__FILE__), 'support/factory_bot')\n"
            end

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
          inside 'spec' do
            insert_into_file 'rails_helper.rb',
              after: rails_helper_insertion_hook do

              "require File.join(File.dirname(__FILE__), 'support/shoulda')\n"
            end

            inside 'support' do
              template 'shoulda.rb'
            end
          end
        end
      end

      def devise_dependency
        @generator.gem 'devise'

        after_bundle do
          generate 'devise:install'
          generate 'devise:views'
          generate 'devise user'

          #note: temporary fix that can be removed once devise progresses #beyond v4.4.3
          # https://github.com/plataformatec/devise/pull/4869/files
          inside 'config/initializers' do
            insert_into_file 'devise.rb',
              after: "Devise.setup do |config|" do
                "  config.secret_key = Rails.application.secret_key_base\n"
            end
          end

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
        @generator.gem 'foundation-rails', '~> 6.5'

        after_bundle do
          generate 'foundation:install foundation'
          # foundation install always messes with the JS manifest
          remove_file 'app/views/layouts/foundation.html.erb'

          inside 'app/assets/javascripts' do
            remove_file 'application.js'
            template 'application.foundation.js', 'application.js'
          end
          # foundation-rails generates an application layout so we
          # must remove it
          remove_file 'app/views/layouts/foundation.html.erb'


        end
      end

      protected

      PACKAGE_PATH = "package.json"
      WEBCONFIG_PATH = "webpack.config.js"

      def add_test_dependency_snippets(snippet_paths)
        snippet_paths.each do |snippet_path|
          snippet = snippet(snippet_path)
          parsed_snippet = JSON.parse(snippet)
          keys = parsed_snippet.keys

          modify_json(package_json_file) do |json|
            keys.each do |key|
              json[key] ||= {}
              json[key].merge!(parsed_snippet[key])
            end
          end
        end
      end

      def create_enzyme_config
        run 'mkdir -p spec/javascript/support'
        devDependencies = parsed_package_json["devDependencies"].keys
        enzymeAdapter = devDependencies.select{ |d| d =~ /^enzyme-adapter-react-[0-9]*/ }[0]

        inside 'spec/javascript/support' do
          template 'enzyme.js'
          gsub_file 'enzyme.js', 'ADAPTER NAME GOES HERE', enzymeAdapter
        end

        inside 'app/javascript/react/components' do
          template "example.test.js"
        end
      end

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
