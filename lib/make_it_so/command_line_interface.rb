require 'thor'
module MakeItSo
  class CommandLineInterface < Thor
    desc "rails <app_name>",
      "generates a rails application based on your specifications"
    option :devise, type: :boolean
    option :js_test_lib, default: "jest"
    def rails(app_name)
      if MakeItSo::Rails::PrerequisiteCheck.new.check
        MakeItSo::RailsAppGenerator.start(ARGV[1..-1])
      end
    end

    desc "sinatra <app_name>",
      "generates a sinatra application based on your specifications"
    def sinatra(*args)
      puts "#{args.first}"
      MakeItSo::SinatraAppGenerator.start(args)
    end

    desc "gosu <app_name>",
      "generates a gosu game template"
    def gosu(*args)
      puts "#{args.first}"
      MakeItSo::GosuAppGenerator.start(args)
    end
  end
end
