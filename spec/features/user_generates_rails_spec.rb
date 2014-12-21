require 'spec_helper'

feature 'user generates rails app' do
  def app_name
    'dummy_rails'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  let(:gemfile_path) { join_paths(app_path, 'Gemfile')}
  let(:rails_spec_helper) { join_paths(app_path, 'spec/rails_helper.rb')}

  before(:all) do
    make_it_so!("rails #{app_name}")
  end

  scenario 'generates a rails app' do
    expect(FileTest.exists?(join_paths(app_path, 'app/models'))).to eq(true)
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

      it 'requires the valid_attribute support file' do
        expect(File.read(rails_spec_helper)).
          to match(/require(.*)support\/valid_attribute/)
      end
    end


  end
end
