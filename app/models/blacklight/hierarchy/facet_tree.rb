# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class FacetTree
      def self.build(prefix:, facet_display:, facet_field:)
        new(prefix: prefix, facet_display: facet_display, facet_field: facet_field).build
      end

      def initialize(prefix:, facet_display:, facet_field:)
        @prefix = prefix
        @facet_config = facet_display.dig(:hierarchy, prefix)
        @facet_field = facet_field
      end

      attr_reader :prefix, :facet_config, :data

      def build
        return unless facet_config
        {}.tap do |tree|
          facet_config.first.each do |key|
            # TODO: remove baked in notion of underscores being part of the blacklight facet field names
            facet_field = [prefix, key].compact.join('_')
            tree[facet_field] ||= {}
            data = @facet_field.display_facet
            next if data.nil?
            data.items.each do |facet_item|
              path = facet_item.value.split(split_regex)
              loc = tree[facet_field]
              loc = loc[path.shift] ||= {} while path.length > 0
              raise(StandardError, "Expected non-empty array after splitting facet value. Original facet value: '#{facet_item.value}'") unless facet_item.value.split(split_regex).present?

              loc[:_] = HierarchicalFacetItem.new(facet_item.value, facet_item.value.split(split_regex).last, facet_item.hits)
            end
          end
        end
      end

      def split_regex
        @split_regex ||= Regexp.new("\s*#{Regexp.escape(facet_config.length >= 2 ? facet_config[1] : ':')}\s*")
      end
    end
  end
end
