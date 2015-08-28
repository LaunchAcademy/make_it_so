module MakeItSo
  class GosuAppGenerator < Thor::Group
    include Thor::Actions

    desc "Creates a new Gosu game"
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
        'spec',
        'img'
      ].each do |dir|
        empty_directory File.join(app_path, dir)
      end
    end

    def app_file
      file_path = 'app.rb'
      template(file_path, File.join(app_path, file_path))
    end

    def readme
      file_path = 'README.md'
      template(file_path, File.join(app_path, file_path))
    end

    def lib
      [
        'lib/keys.rb',
        'lib/bounding_box.rb'
      ].each do |file_path|
        template(file_path, File.join(app_path, file_path))
      end
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
        "gosu")

      File.expand_path(template_path)
    end

    protected
    def app_path
      name
    end
  end
end
