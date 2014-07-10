#require 'rubygems'
#require 'bundler/setup'

ENV["RAILS_ENV"] ||= "test"

require 'engine_cart'
EngineCart.load_application!

require 'coveralls'
Coveralls.wear!

require 'blacklight-hierarchy'

require 'rsolr'
require 'capybara/rails'
require 'capybara/rspec'
require 'rspec/rails'

# Setup blacklight environment
Blacklight.solr_config = { :url => 'http://127.0.0.1:8983/solr' }

require 'vcr'

VCR.configure do |config|
  config.hook_into :fakeweb
#  config.hook_into :webmock
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.configure_rspec_metadata!
  config.default_cassette_options = {
      :serialize_with => :psych 
  }
end


RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Capybara::DSL
end
