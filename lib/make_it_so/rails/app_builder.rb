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
        end
      end
    end
  end
end
