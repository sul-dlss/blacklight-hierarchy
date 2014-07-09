$:.push File.expand_path("../lib", __FILE__)

require File.join(File.dirname(__FILE__), "lib/blacklight/hierarchy/version")

Gem::Specification.new do |s|
  s.name        = "blacklight-hierarchy"
  s.version     = Blacklight::Hierarchy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael B. Klein"]
  s.email       = ["dlss-dev@lists.stanford.edu"]
  s.homepage    = "https://github.com/sul-dlss/blacklight-hierarchy"
  s.summary     = "Hierarchical Facets for Blacklight"
  s.description = "Allows delimited Solr facets to become hierarchical trees in Blacklight."

  s.files         = Dir["{app,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files    = Dir["{spec,test}/**/*"]
  s.require_paths = ['lib']

  s.add_dependency "rails", '~> 4.1'
  s.add_dependency "blacklight", "~> 5", "< 6"
  
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "engine_cart"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "capybara"
  s.add_development_dependency "vcr"
  s.add_development_dependency "coveralls"
end
