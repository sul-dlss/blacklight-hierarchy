$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "blacklight/hierarchy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blacklight-hierarchy"
  s.version     = Blacklight::Hierarchy::VERSION
  s.authors     = ["Michael B. Klein"]
  s.email       = ["mbklein@stanford.edu"]
  s.homepage    = "https://github.com/sul-dlss/blacklight-hierarchy"
  s.summary     = "Hierarchical Facets for Blacklight"
  s.description = "Allows delimited solr facets to become hierarchical trees in Blacklight."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "blacklight", "~> 3.2"
  s.add_development_dependency "sqlite3"
end
