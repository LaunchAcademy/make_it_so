require 'thor'
module MakeItSo
  class CommandLineInterface < Thor
    desc "rails <app_name>",
      "generates a rails application based on your specifications"
    option :devise
    def rails(app_name)
      puts "#{app_name}"
      MakeItSo::RailsAppGenerator.start([app_name])
    end

    desc "sinatra <app_name>",
      "generates a sinatra application based on your specifications"
    def sinatra(*args)
      puts "#{args.first}"
      MakeItSo::SinatraAppGenerator.start(args)
    end
  end
end
