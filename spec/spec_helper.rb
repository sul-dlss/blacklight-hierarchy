#require 'rubygems'
#require 'bundler/setup'

ENV["RAILS_ENV"] ||= "test"

require 'engine_cart'
EngineCart.load_application!

require 'coveralls'
Coveralls.wear!

require 'blacklight-hierarchy'
require 'rsolr'

require 'rspec/rails'

# Setup blacklight environment
Blacklight.solr_config = { :url => 'http://127.0.0.1:8983/solr' }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Capybara::DSL
end
