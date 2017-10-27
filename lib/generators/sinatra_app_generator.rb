module MakeItSo
  class SinatraAppGenerator < Thor::Group
    include Thor::Actions

    desc "Creates a new Sinatra application"
    argument :name,
      type: :string,
      desc: "The name of the new application"

    class_option :rspec,
      type: :boolean,
      default: true,
      desc: 'install rspec'

    def directories
      [
        'lib',
        'views',
        'public/stylesheets',
        'public/javascripts'
      ].each do |dir|
        empty_directory File.join(app_path, dir)
      end
    end

    def app_file
      file_path = 'app.rb'
      template(file_path, File.join(app_path, file_path))
    end

    def rakefile
      file_path = 'Rakefile'
      template(file_path, File.join(app_path, file_path))
    end

    def view_files
      [
        'views/layout.erb',
        'views/index.erb'
      ].each do |file_path|
        template(file_path, File.join(app_path, file_path))
      end
    end

    def asset_files
      [
        'public/javascripts/app.js',
        'public/stylesheets/app.css'
      ].each do |file_path|
        create_file(File.join(app_path, file_path))
      end
    end

    def rackup_file
      file_path = 'config.ru'
      template(file_path, File.join(app_path, file_path))
    end

    def gemfile
      file_path = 'Gemfile'
      template(file_path, File.join(app_path, file_path))
    end

    def gitignore
      file_path = '.gitignore'
      template(file_path, File.join(app_path, file_path))
    end

    def rspec
      if options.rspec?
        empty_directory File.join(app_path, 'spec/features')
        spec_helper = 'spec/spec_helper.rb'
        template(spec_helper, File.join(app_path, spec_helper))

        dot_rspec = '.rspec'
        template(dot_rspec, File.join(app_path, dot_rspec))
      end
    end

    def self.source_root
      template_path = File.join(
        File.dirname(__FILE__),
        "..",
        "..",
        "templates",
        "sinatra")

      File.expand_path(template_path)
    end

    protected
    def app_path
      name
    end
  end
end
