module MakeItSoSpecHelpers
  def make_it_so!(subcommand_with_args)
    Dir.chdir(tmp_path) do
      Bundler.with_unbundled_env do
        `#{join_paths(bin_path, 'make_it_so')} #{subcommand_with_args}`
      end
    end
  end

  def make_tmp_path
    FileUtils.mkdir_p(tmp_path)
  end

  def purge_tmp_dir
    FileUtils.rm_rf(tmp_path)
  end

  protected
  def bin_path
    join_paths(root_path, 'bin')
  end

  def tmp_path
    File.join(Dir.tmpdir, 'make_it_so')
  end

  def root_path
    join_paths(File.dirname(__FILE__), '../../')
  end

  def join_paths(*paths)
    File.join(*paths)
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

  def in_package_json?(path, &block)
    contents = File.read(path)
    json = JSON.parse(contents)
    yield(json)
  end

  def read_file(file_path)
    File.read(File.join(app_path, file_path))
  end

  def major_version(version_string)
    version_array(version_string)[0]
  end

  def minor_version(version_string)
    version_array(version_string)[1]
  end

  def patch_version(version_string)
    version_array(version_string)[2]
  end

  def version_array(version_string)
    version_string.delete!("^")
    version_string.delete!("~")
    version_array = version_string.split(".")
    version_array.map{ |string| string.to_i }
  end
end

RSpec.configure do |config|
  config.include(MakeItSoSpecHelpers)

  config.before(:all) do
    purge_tmp_dir
    make_tmp_path
  end

  config.after(:all) do
    purge_tmp_dir
  end
end
