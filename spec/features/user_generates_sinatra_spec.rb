require 'spec_helper'

describe 'user generates sinatra app' do
  def app_name
    'dummy_sinatra'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  before(:all) do
    make_it_so!("sinatra #{app_path}")
  end

  scenario 'includes sinatra in the app.rb file' do
    expect(FileTest.exists?(join_paths(app_path, 'app.rb'))).
      to be(true)
  end

  scenario 'creates a lib directory' do
    expect(has_dir?('lib')).to be(true)
  end

  scenario 'creates a public/javascripts directory' do
    expect(has_dir?('public/javascripts')).to be(true)
  end

  scenario 'creates a public/stylesheets directory' do
    expect(has_dir?('public/stylesheets')).to be(true)
  end

  scenario 'creates a views directory' do
    expect(has_dir?('views')).to be(true)
  end

  scenario 'includes a config.ru file' do
    expect(has_file?('config.ru')).to be(true)
  end

  scenario 'includes a Gemfile' do
    expect(has_file?('Gemfile')).to be(true)
  end

  scenario 'includes sinatra in the Gemfile' do
    expect(in_gemfile?('sinatra')).
      to be(true)
  end

  scenario 'creates a public/javascripts/app.js' do
    expect(has_file?('public/javascripts/app.js')).to be(true)
  end

  scenario 'creates a public/javascripts/app.css' do
    expect(has_file?('public/javascripts/app.css')).to be(true)
  end

  scenario 'creates a layout file' do
    expect(has_file?('views/layout.erb')).to be(true)
  end

  scenario 'creates an index file' do
    expect(has_file?('views/index.erb')).to be(true)
  end

  context 'rspec' do
    scenario 'creates a spec_helper' do
      expect(has_file?('spec/spec_helper.rb')).to be(true)
    end

    scenario 'creates a spec directory' do
      expect(has_dir?('spec')).to be(true)
    end

    scenario 'creates a spec/features directory' do
      expect(has_dir?('spec/features')).to be(true)
    end

    scenario 'includes rspec as a dependency' do
      expect(in_gemfile?('rspec')).to be(true)
    end

    scenario 'includes capybara as a dependency' do
      expect(in_gemfile?('capybara')).to be(true)
    end

    scenario 'includes launchy as a dependency' do
      expect(in_gemfile?('launchy')).to be(true)
    end
  end

  def has_dir?(relative_path)
    File.directory?(join_paths(app_path, relative_path))
  end

  def has_file?(relative_path)
    FileTest.exists?(join_paths(app_path, relative_path))
  end

  def in_gemfile?(gem_name)
    File.read(join_paths(app_path, 'Gemfile')).
      match(/gem.*#{Regexp.escape(gem_name)}/).present?
  end
end
