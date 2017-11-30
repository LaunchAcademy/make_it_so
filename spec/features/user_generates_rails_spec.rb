require 'spec_helper'

feature 'user generates rails app' do
  def app_name
    'dummy_rails'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  let(:css_manifest_path) { join_paths(app_path, 'app/assets/stylesheets/application.css') }

  let(:gemfile_path) { join_paths(app_path, 'Gemfile')}
  let(:package_json_path) { join_paths(app_path, 'package.json')}
  let(:rails_spec_helper) { join_paths(app_path, 'spec/rails_helper.rb')}

  before(:all) do
    make_it_so!("rails #{app_name}")
  end

  scenario 'generates a rails app' do
    expect(FileTest.exists?(join_paths(app_path, 'app/models'))).to eq(true)
  end

  scenario 'creates an application.js manifest' do
    js_file = join_paths(app_path, 'app/assets/javascripts/application.js')
    expect(FileTest.exists?(js_file)).to eq(true)
  end

  scenario 'creates an application.css manifest' do
    expect(FileTest.exists?(css_manifest_path)).to eq(true)
  end

  scenario 'includes the flash in the layout' do
    app_layout = File.join(app_path, 'app/views/layouts/application.html.erb')
    expect(File.read(app_layout)).to include('flash')
  end

  scenario 'includes viewport meta tag in layout for mobile' do
    app_layout = File.join(app_path, 'app/views/layouts/application.html.erb')
    expect(File.read(app_layout)).to include('initial-scale=1.0')
    expect(File.read(app_layout)).to include('viewport')
  end

  scenario 'creates a valid gemfile' do
    words = ['source', '#', 'gem', 'group', 'end']

    File.readlines('Gemfile').each do |line|
      unless line.strip.empty?
        expect(line.strip.start_with?(*words)).to eq(true)
      end
    end
  end

  scenario 'creates a valid package.json' do
    words = ['name', 'version', 'description', 'main', 'scripts' ]

    File.readlines('package.json').each do |line|
      unless line.strip.empty?
        expect(line.strip.start_with?(*words)).to eq(true)
      end
    end
  end

  context 'pry-rails' do
    it 'is added as a dependency' do
      expect(File.read(gemfile_path)).to match(/gem(.*)pry-rails/)
    end
  end

  context 'rspec' do
    it 'eliminates test/unit' do
      expect(FileTest.exists?(join_paths(app_path, 'test'))).to_not eq(true)
    end

    it 'inserts a spec_helper' do
      spec_helper = join_paths(app_path, 'spec/spec_helper.rb')
      expect(FileTest.exists?(spec_helper)).to eq(true)
    end

    context 'byebug' do
      it 'removes the byebug dependency' do
        expect(File.read(gemfile_path)).to_not match(/gem(.*)byebug/)
      end
    end

    context 'capybara' do
      it 'includes capybara as a Gemfile dependency' do
        expect(File.read(gemfile_path)).to include('capybara')
      end

      it 'includes launch as a Gemfile dependency' do
        expect(File.read(gemfile_path)).to include('launchy')
      end

      it 'includes capybara in the rails_helper' do
        expect(File.read(rails_spec_helper)).to match(/require \'capybara\/rspec\'/)
      end
    end

    context 'factory_bot' do
      it 'includes a factory_bot support file' do
        fb_support_path = join_paths(app_path, 'spec/support/factory_bot.rb')
        expect(FileTest.exists?(fb_support_path)).to eq(true)
      end

      it 'includes the factory_bot gem' do
        expect(File.read(gemfile_path)).to include('factory_bot')
      end

      it 'requires all support files, including factory bot' do
        expect(File.read(rails_spec_helper)).
          to include("\nDir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }\n\n")
      end
    end

    context 'valid_attribute' do
      it 'includes the valid_attribute gem' do
        expect(File.read(gemfile_path)).to include('valid_attribute')
      end

      it 'creates the valid_attribute support file' do
        support_path = join_paths(app_path, 'spec/support/valid_attribute.rb')
        expect(FileTest.exists?(support_path)).to eq(true)
      end

      it 'requires the valid_attribute support file' do
        expect(File.read(rails_spec_helper)).
          to match(/require(.*)support\/valid_attribute/)
      end
    end

    context 'shoulda' do
      it 'includes shoulda-matchers in the gemfile' do
        expect(File.read(gemfile_path)).to include('shoulda-matchers')
      end

      it 'requires shoulda-matchers in the rails_helper' do
        expect(File.read(rails_spec_helper)).
          to include("require 'shoulda-matchers'")
      end
    end

    context 'teaspoon' do
      it 'includes teaspoon-jasmine in the Gemfile' do
        expect(File.read(gemfile_path)).to include('teaspoon-jasmine')
      end

      it 'generates a spec/javascripts directory' do
        expect(FileTest.exists?(join_paths(app_path, 'spec/javascripts'))).to eq(true)
      end
    end
  end

  context 'devise' do
    it 'adds devise as a dependency' do
      expect(File.read(gemfile_path)).to include('devise')
    end

    it 'generates devise' do
      devise_initializer = File.join(app_path, 'config/initializers/devise.rb')
      expect(FileTest.exists?(devise_initializer)).to eq(true)
    end

    it 'generates devise views' do
      devise_views = File.join(app_path, 'app/views/devise')
      expect(FileTest.exists?(devise_views)).to eq(true)
    end

    it 'creates a user model' do
      user_model = File.join(app_path, 'app/models/user.rb')
      expect(FileTest.exists?(user_model)).to eq(true)
    end

    it 'creates a user_signs_up feature spec' do
      feature_spec = File.join(app_path, 'spec/features/user_signs_up_spec.rb')
      expect(FileTest.exists?(feature_spec)).to eq(true)
    end

    it 'creates a user_signs_in feature spec' do
      feature_spec = File.join(app_path, 'spec/features/user_signs_in_spec.rb')
      expect(FileTest.exists?(feature_spec)).to eq(true)
    end

    it 'creates a user_signs_out feature spec' do
      feature_spec = File.join(app_path, 'spec/features/user_signs_out_spec.rb')
      expect(FileTest.exists?(feature_spec)).to eq(true)
    end
  end

  context 'foundation' do
    it 'generates foundation' do
      expect(File.read(css_manifest_path)).to include('foundation_and_overrides')
    end

    it 'includes modernizr in the layout' do
      expect(File.read(File.join(app_path, 'app/views/layouts/application.html.erb'))).to include('modernizr')
    end
  end

  context 'react' do
    it 'generates a react folder' do
      expect(FileTest.exists?(join_paths(app_path, 'react'))).to eq(true)
    end

    it 'includes * in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        return true if json["devDependencies"]["jasmine-enzyme"] != nil
      end
    end

  end
end
