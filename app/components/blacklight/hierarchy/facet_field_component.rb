# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class FacetFieldComponent < ::ViewComponent::Base
      def initialize(field_name:, tree:, key:)
        @field_name = field_name
        @tree = tree
        @key = key
      end

      attr_reader :field_name, :tree, :key, :id

      def subset
        @subset ||= tree.reject { |k, _v| !k.is_a?(String) }
      end

      def li_class
        subset.empty? ? 'h-leaf' : 'h-node'
      end

      def controller_name
        subset.empty? ? '' : 'b-h-collapsible'
      end

      def item
        tree[:_]
      end

      def qfacet_selected?
        config = helpers.facet_configuration_for_field(field_name)
        helpers.search_state.filter(config).include?(item.qvalue)
      end

      def ul_id
        @ul_id ||= "b-h-#{SecureRandom.alphanumeric(10)}"
      end
    end
  end
end
