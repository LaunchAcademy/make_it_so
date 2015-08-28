require 'spec_helper'

describe 'user generates gosu app' do
  def app_name
    'dummy_gosu'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  before(:all) do
    make_it_so!("gosu #{app_path}")
  end

  scenario 'includes gosu in the game.rb file' do
    expect(FileTest.exists?(join_paths(app_path, 'game.rb'))).
      to be(true)
  end

  scenario 'creates a lib directory' do
    expect(has_dir?('lib')).to be(true)
  end

  scenario 'creates a img directory' do
    expect(has_dir?('img')).to be(true)
  end

  scenario 'creates a README' do
    expect(has_file?('README.md')).to be(true)
  end

  scenario 'creates a lib/keys module' do
    expect(has_file?('lib/keys.rb')).to be(true)
  end

  scenario 'creates bounding box' do
    expect(has_file?('lib/bounding_box.rb')).to be(true)
  end

  scenario '.gitignore' do
    expect(has_file?('.gitignore')).to be(true)
  end

  context 'Gemfile' do
    scenario 'includes a Gemfile' do
      expect(has_file?('Gemfile')).to be(true)
    end

    scenario 'includes gosu in the Gemfile' do
      expect(in_gemfile?('gosu')).
        to be(true)
    end

    scenario 'includes pry in the Gemfile' do
      expect(in_gemfile?('pry')).
        to be(true)
    end

    scenario 'includes rspec in the Gemfile' do
      expect(in_gemfile?('rspec')).
        to be(true)
    end
  end

  context 'rspec' do
    scenario 'creates a spec_helper' do
      expect(has_file?('spec/spec_helper.rb')).to be(true)
    end

    scenario 'creates a .rspec file' do
      expect(has_file?('.rspec')).to be(true)
    end

    scenario 'creates a spec directory' do
      expect(has_dir?('spec')).to be(true)
    end

    scenario 'includes rspec as a dependency' do
      expect(in_gemfile?('rspec')).to be(true)
    end
  end
end

