require 'rails/generators/rails/app/app_generator'

module MakeItSo
  class RailsAppGenerator < ::Rails::Generators::AppGenerator
    source_root(MakeItSo.source_root(:rails))

    class_option :rspec,
      type: :boolean,
      default: true,
      desc: 'install rspec'

    class_option :devise,
      type: :boolean,
      default: true,
      desc: 'install devise: complete with acceptance tests'

    #override database to default to postgres
    class_option :database,
      type: :string,
      aliases: '-d',
      default: 'postgresql',
      desc: "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :foundation,
      type: :boolean,
      default: true,
      desc: 'generate foundation support'

    # turbolinks is the devil
    class_option :skip_turbolinks,
      type: :boolean,
      default: true,
      desc: 'Skip turbolinks gem'

    def initialize(*args)
      super
      if @options[:rspec]
        # don't generate Test::Unit - we have to dup to unfreeze
        @options = @options.dup
        @options[:skip_test_unit] = true
      end
    end

    def finish_template
      super

      build 'pry_rails_dependency'
      build 'base_stylesheets'
      build 'eliminate_byebug'
      unless options[:skip_javascript]
        build 'base_javascripts'
      end

      build 'application_controller'
      if options[:rspec]
        build 'rspec_dependency'
        #build 'fix_generators'
        build 'factory_girl_rspec'
        build 'valid_attribute_rspec'
        build 'shoulda_rspec'
      end

      if options[:devise]
        build 'devise_dependency'
      end

      if options[:foundation]
        build 'foundation_dependency'
      end
    end

    protected

    def get_builder_class
      MakeItSo::Rails::AppBuilder
    end

  end
end

[
  MakeItSo.source_root(:rails),
  Rails::Generators::AppGenerator.source_root
].each do |path|
  MakeItSo::RailsAppGenerator.source_paths << path
end
