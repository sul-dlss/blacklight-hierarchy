require 'rails/generators'

module BlacklightHierarchy
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def assets
      copy_file "blacklight_hierarchy.css.scss", "app/assets/stylesheets/blacklight_hierarchy.css.scss"
      copy_file "blacklight_hierarchy.js", "app/assets/javascripts/blacklight_hierarchy.js"
    end
  end
end