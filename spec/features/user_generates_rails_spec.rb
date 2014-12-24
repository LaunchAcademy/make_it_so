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

  context 'rspec' do
    it 'eliminates test/unit' do
      expect(FileTest.exists?(join_paths(app_path, 'test'))).to_not eq(true)
    end

    it 'inserts a spec_helper' do
      spec_helper = join_paths(app_path, 'spec/spec_helper.rb')
      expect(FileTest.exists?(spec_helper)).to eq(true)
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

    context 'factory_girl' do
      it 'includes a factory_girl support file' do
        fg_support_path = join_paths(app_path, 'spec/support/factory_girl.rb')
        expect(FileTest.exists?(fg_support_path)).to eq(true)
      end

      it 'includes the factory_girl gem' do
        expect(File.read(gemfile_path)).to include('factory_girl')
      end

      it 'requires the factory_girl support file' do
        expect(File.read(rails_spec_helper)).
          to match(/require(.*)support\/factory_girl/)
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
  end

  context 'foundation' do
    it 'generates foundation' do
      expect(File.read(css_manifest_path)).to include('foundation_and_overrides')
    end
  end
end
