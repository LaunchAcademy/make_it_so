    config.generators do |generate|
      #don't generate noise in the rails stack
      generate.helper false
      generate.stylesheets false
      generate.javascripts false

      #TODO: figure out how to make this ERB
      generate.test_framework :rspec

      #don't generate unused spec files
      generate.view_specs false
      generate.controller_specs false
    end
