require 'thor'
module MakeItSo
  class CommandLineInterface < Thor
    desc "rails <app_name>", "generates a rails application based on your specifications"
    option :devise
    def rails(app_name)
      puts "#{app_name}"
      MakeItSo::RailsAppGenerator.start([app_name])
    end
  end
end
