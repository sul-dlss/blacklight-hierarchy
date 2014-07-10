require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../test_app_templates", __FILE__)

  def add_gems
    gem 'blacklight'
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  # This is only necessary for Rails 3
  def remove_index
    remove_file "public/index.html"
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)

    generate 'blacklight:install'
  end

  def run_hierarchy_install
    generate 'blacklight_hierarchy:install'
  end

end