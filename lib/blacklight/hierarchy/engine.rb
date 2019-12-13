require 'blacklight'
require 'rails'

module Blacklight
  module Hierarchy
    class Engine < Rails::Engine
      config.closed_icon = '⊞'
      config.opened_icon = '⊟'
    end
  end
end
