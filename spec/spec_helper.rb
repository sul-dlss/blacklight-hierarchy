ENV['RAILS_ENV'] ||= 'test'

require 'rsolr'

require 'engine_cart'
EngineCart.load_application!

require 'coveralls'
Coveralls.wear!

require 'capybara/rspec'
require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Capybara::DSL
end
