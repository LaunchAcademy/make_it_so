require 'rubygems'

module MakeItSo
  module Rails
    class PrerequisiteCheck 
      include Thor::Base
      include Thor::Actions

      def check
        say "Checking Rails version...", :yellow
        begin
          require "rails"
          puts ::Rails.version
          if ::Rails.version != MakeItSo::Rails::VERSION
            say "Rails versions check FAILED - execute the following", :red 
            say "gem uninstall rails -a && gem install rails -v #{MakeItSo::Rails::VERSION}"
            return false
          else
            say "Rails version MATCH", :green
            return true
          end
        rescue LoadError => e
          say "Rails not installed", :red
          return false
        end
      end
    end
  end
end