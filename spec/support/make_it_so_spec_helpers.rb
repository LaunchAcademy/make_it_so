module MakeItSoSpecHelpers
  def make_it_so!(subcommand_with_args)
    Dir.chdir(tmp_path) do
      Bundler.with_clean_env do
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
    '/tmp/make_it_so'
  end

  def root_path
    join_paths(File.dirname(__FILE__), '../../')
  end

  def join_paths(*paths)
    File.join(*paths)
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
