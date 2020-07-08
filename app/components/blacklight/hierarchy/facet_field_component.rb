# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class FacetFieldComponent < ::ViewComponent::Base
      def initialize(field_name:, tree:, key:)
        @field_name = field_name
        @tree = tree
        @key = key
        @id = SecureRandom.uuid
      end

      attr_reader :field_name, :tree, :key, :id

      def subset
        @subset ||= tree.reject { |k, _v| !k.is_a?(String) }
      end

      def li_class
        subset.empty? ? 'h-leaf' : 'h-node'
      end

      def item
        tree[:_]
      end

      def qfacet_selected?
        config = helpers.facet_configuration_for_field(field_name)
        helpers.search_state.has_facet?(config, value: item.qvalue)
      end
    end
  end
end
