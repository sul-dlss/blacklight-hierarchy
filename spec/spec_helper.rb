require 'rubygems'

require 'combustion'
require 'blacklight/engine'
require 'blacklight/hierarchy/engine'
require 'rsolr'
require 'rsolr-ext'
require 'rsolr-ext/response'
require 'capybara/rspec'
Combustion.initialize!


# Setup blacklight environment
Blacklight.solr_config = { :url => 'http://127.0.0.1:8983/solr' }

require 'vcr'

VCR.configure do |config|
  config.hook_into :fakeweb
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.default_cassette_options = {
      :serialize_with => :syck 
  }
end

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros

end
