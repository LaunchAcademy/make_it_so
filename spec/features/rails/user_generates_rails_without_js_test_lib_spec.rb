require 'spec_helper'

feature "user generates rails app without js test framework" do
  def app_name
    'dummy_rails'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  before(:all) do
    make_it_so!("rails #{app_name} --js-test-lib false")
  end

  let(:package_json_path) { File.join(app_path, 'package.json') }

  it 'does not create a karma.config' do
    karma_config = File.join(app_path, 'karma.conf.js')
    expect(FileTest.exists?(karma_config)).to eq(false)
  end

  it 'does not create a testHelper.js' do
    test_helper = File.join(app_path, 'spec/javascript/testHelper.js')
    expect(FileTest.exists?(test_helper)).to eq(false)
  end

  it 'does not create an enzyme config file' do
    test_helper = File.join(app_path, 'spec/javascript/support/enzyme.js')
    expect(FileTest.exists?(test_helper)).to eq(false)
  end

  it 'does not include karma or jest in package.json' do
    in_package_json?(File.join(app_path, 'package.json')) do |json|
      expect(json["devDependencies"]["karma"]).to be_nil
      expect(json["devDependencies"]["jest"]).to be_nil
    end
  end

  it 'does not include jasmine in package.json' do
    in_package_json?(File.join(app_path, 'package.json')) do |json|
      expect(json["devDependencies"]["jasmine-core"]).to be_nil
    end
  end

  it 'does not add jest or karma as the test script in package.json' do
    in_package_json?(package_json_path) do |json|
      expect(json["scripts"]["test"]).to_not include("jest")
      expect(json["scripts"]["test"]).to_not include("karma")
    end
  end
end
