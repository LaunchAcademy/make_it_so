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

  scenario 'skips active_storage' do
    expect(FileTest.exists?(join_paths(app_path, 'config/storage.yml'))).to eq(false)
  end

  scenario 'creates a valid gemfile' do
    words = ['source', '#', 'gem', 'group', 'end', 'ruby']

    File.readlines('Gemfile').each do |line|
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

      it 'includes launchy as a Gemfile dependency' do
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

      it 'requires the factory_bot support file' do
        expect(File.read(rails_spec_helper)).
          to include("\nrequire File.join(File.dirname(__FILE__), 'support/factory_bot')\n")
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

      it 'includes a shoulda file in the support directory' do
        expect(FileTest.exists?(join_paths(app_path, 'spec/support/shoulda.rb')))
      end
    end

    context 'database_cleaner' do
      it 'includes database_cleaner in the gemfile' do
        expect(File.read(gemfile_path)).to include('database_cleaner')
      end

      it 'creates the database_cleaner support file' do
        support_path = join_paths(app_path, 'spec/support/database_cleaner.rb')
        expect(FileTest.exists?(support_path)).to eq(true)
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
      expect(read_file('app/views/layouts/application.html.erb')).to include('modernizr')
    end
  end

  context 'react' do
    it 'generates a packs file' do
      expect(FileTest.exists?(join_paths(app_path, 'app/javascript/packs/application.js'))).to eq(true)
    end

    it 'includes react in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        react = json["dependencies"]["react"]
        expect(major_version(react)).to be 16
        expect(minor_version(react)).to be 8
      end
    end

    it 'includes redbox-react in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        expect(json["dependencies"]["redbox-react"]).to_not be_nil
      end
    end

    it 'includes react-dom in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        react_dom = json["dependencies"]["react-dom"]
        expect(major_version(react_dom)).to be 16
        expect(minor_version(react_dom)).to be 8
      end
    end

    it 'includes react-router-dom in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        expect(json["dependencies"]["react-router-dom"]).to_not be_nil
      end
    end
  end

  context 'karma' do
    it 'creates a karma.config' do
      karma_config = File.join(app_path, 'karma.conf.js')
      expect(FileTest.exists?(karma_config)).to eq(true)
    end

    it 'creates a testHelper.js' do
      test_helper = File.join(app_path, 'spec/javascript/testHelper.js')
      expect(FileTest.exists?(test_helper)).to eq(true)
    end

    it 'includes karma in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        expect(json["devDependencies"]["karma"]).to_not be_nil
      end
    end

    it 'includes jasmine in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        expect(json["devDependencies"]["jasmine-core"]).to_not be_nil
      end
    end

    it 'includes fetch-mock' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        expect(json["devDependencies"]["fetch-mock"]).to_not be_nil
      end
    end

    it 'adds coverage/* to gitignore' do
      expect(read_file('.gitignore')).to include("coverage/*\n")
    end
  end

  context 'dotenv' do
    it 'adds dotenv-rails to Gemfile' do
      expect(File.read(gemfile_path)).to match(/gem(.*)dotenv-rails/)
    end

    it 'adds .env to gitignore' do
      expect(read_file('.gitignore')).to include(".env\n")
    end

    it 'creates a .env file' do
      expect(FileTest.exists?(File.join(app_path, '.env'))).to eq(true)
    end

    it 'creates a .env.example file' do
      expect(FileTest.exists?(File.join(app_path, '.env.example'))).to eq(true)
    end
  end

  context 'enzyme' do
    it 'includes enzyme in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        enzyme = json["devDependencies"]["enzyme"]
        expect(major_version(enzyme)).to be 3
        expect(minor_version(enzyme)).to be 10
      end
    end

    it 'includes enzyme-adapter-react-16 in package.json' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        adapter = json["devDependencies"]["enzyme-adapter-react-16"]
        expect(major_version(adapter)).to be 1
        expect(minor_version(adapter)).to be 14
      end
    end

    it 'configures enzyme with adapter in testHelper' do
      testHelper = read_file('spec/javascript/testHelper.js')
      expect(testHelper).to include("Enzyme.configure({ adapter: new EnzymeAdapter() })")
    end
  end

  context 'babel' do
    it 'includes necessary babel packages in package.json as dev dependencies' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        expect(json["devDependencies"]["@babel/core"]).to_not be_nil
        expect(json["devDependencies"]["@babel/preset-env"]).to_not be_nil
        expect(json["devDependencies"]["@babel/preset-react"]).to_not be_nil
        expect(json["devDependencies"]["babel-loader"]).to_not be_nil
      end
    end

    it 'includes @babel/polyfill in package.json as standard dependency' do
      in_package_json?(File.join(app_path, 'package.json')) do |json|
        babel_polyfill = json["dependencies"]["@babel/polyfill"]
        expect(major_version(babel_polyfill)).to equal 7
      end
    end

    it 'imports @babel/polyfill in App.js' do
      expect(read_file('app/javascript/react/components/App.js')).to include("import '@babel/polyfill'")
    end

    it 'sets necessary presets in .babelrc' do
      babelrc = read_file('.babelrc')
      expect(babelrc).to include("@babel/env")
      expect(babelrc).to include("@babel/react")
    end

    it 'karma.conf.js uses @babel/polyfill' do
      expect(read_file('karma.conf.js')).to include("node_modules/@babel/polyfill/dist/polyfill.js")
    end
  end
end

feature 'jest' do
  def app_name
    'dummy_rails'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  before(:all) do
    make_it_so!("rails #{app_name} --jest")
  end

  let(:package_json_path) { File.join(app_path, 'package.json') }


  scenario 'adds jest as a dependency' do
    in_package_json?(package_json_path) do |json|
      expect(json["devDependencies"]["jest"]).to_not be_nil
    end
  end

  scenario 'adds enzyme as a dependency' do
    in_package_json?(package_json_path) do |json|
      expect(json["devDependencies"]["enzyme"]).to_not be_nil
    end
  end

  scenario 'adds fetch-mock as a dependency' do
    in_package_json?(package_json_path) do |json|
      expect(json["devDependencies"]["fetch-mock"]).to_not be_nil
    end
  end

  scenario 'adds jest as the test script in package.json' do
    in_package_json?(package_json_path) do |json|
      expect(json["scripts"]["test"]).to include("jest")
    end
  end

  scenario 'adds spec/javascripts to roots' do
    in_package_json?(package_json_path) do |json|
      expect(json["jest"]).to_not be_nil
      expect(json["jest"]["roots"]).to include("spec/javascript")
    end
  end

  scenario 'adds node_modules to modules directory' do
    in_package_json?(package_json_path) do |json|
      expect(json["jest"]).to_not be_nil
      expect(json["jest"]["moduleDirectories"]).to_not be_nil
      expect(json["jest"]["moduleDirectories"]).to include("node_modules")
    end
  end

  scenario 'adds app/javascript to modules directory' do
    in_package_json?(package_json_path) do |json|
      expect(json["jest"]).to_not be_nil
      expect(json["jest"]["moduleDirectories"]).to_not be_nil
      expect(json["jest"]["moduleDirectories"]).to include("app/javascript")
    end
  end

  scenario 'adds testURL to jest configuration' do
    in_package_json?(package_json_path) do |json|
      expect(json["jest"]).to_not be_nil
      expect(json["jest"]["testURL"]).to_not be_nil
      expect(json["jest"]["testURL"]).to eq("http://localhost/")
    end
  end

  scenario 'adds a spec/javascript/support/enzyme.js file' do
    support_file = File.join(app_path, 'spec/javascript/support/enzyme.js')
    expect(FileTest.exists?(support_file)).to eq(true)
  end

  scenario 'adds spec/javascript/support/enzyme.js to setup' do
    in_package_json?(package_json_path) do |json|
      expect(json["jest"]).to_not be_nil
      expect(json["jest"]["setupFiles"]).to include('./spec/javascript/support/enzyme.js')
    end
  end
end
