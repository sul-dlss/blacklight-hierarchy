require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  def add_gems
    gem 'blacklight' unless Bundler.locked_gems.dependencies.key? 'blacklight'
    Bundler.with_clean_env do
      run 'bundle install'
    end
  end

  def run_blacklight_generator
    say_status('warning', 'GENERATING BL', :yellow)

    generate 'blacklight:install'
  end

  def run_hierarchy_install
    generate 'blacklight_hierarchy:install'
  end

  def create_images_directory
    run 'mkdir app/assets/images'
  end
end
