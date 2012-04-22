$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "blacklight/hierarchy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blacklight-hierarchy"
  s.version     = Blacklight::Hierarchy::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Blacklight::Hierarchy."
  s.description = "TODO: Description of Blacklight::Hierarchy."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "blacklight", "~> 3.2.0"
  s.add_development_dependency "sqlite3"
end
