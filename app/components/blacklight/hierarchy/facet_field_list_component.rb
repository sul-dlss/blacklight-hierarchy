# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class FacetFieldListComponent < Blacklight::FacetFieldListComponent
      DELIMETER = '_'

      # @param [Blacklight::Configuration::FacetField] as defined in controller with config.add_facet_field (and with :partial => 'blacklight/hierarchy/facet_hierarchy')
      # @return [String] html for the facet tree
      def tree
        @tree ||= begin
          facet_tree_for_prefix = facet_tree
          facet_tree_for_prefix ? facet_tree_for_prefix[field_name] : nil
        end
      end

      def field_name
        @facet_field.facet_field.field
      end

      # @return [String]  a key to access the rest of the hierarchy tree, as defined in controller config.facet_display[:hierarchy] declaration.
      #  e.g. if you had this in controller:
      #   config.facet_display = {
      #     :hierarchy => {
      #       'wf' => [['wps','wsp','swp'], ':'],
      #       'callnum_top' => [['facet'], '/'],
      #       'exploded_tag' => [['ssim'], ':']
      #    }
      #  }
      # then possible hkey values would be 'wf', 'callnum_top', and 'exploded_tag'.
      #
      # the key in the :hierarchy hash is the "prefix" for the solr field with the hierarchy info.  the value
      #  in the hash is a list, where the first element is a list of suffixes, and the second element is the delimiter
      #  used to break up the sections of hierarchical data in the solr field being read.  when joined, the prefix and
      #  suffix should form the field name.  so, for example, 'wf_wps', 'wf_wsp', 'wf_swp', 'callnum_top_facet', and
      #  'exploded_tag_ssim' would be the solr fields with blacklight-hierarchy related configuration according to the
      #  hash above.  ':' would be the delimiter used in all of those fields except for 'callnum_top_facet', which would
      #  use '/'.  exploded_tag_ssim might contain values like ['Book', 'Book : Multi-Volume Work'], and callnum_top_facet
      #  might contain values like ['LB', 'LB/2395', 'LB/2395/.C65', 'LB/2395/.C65/1991'].
      # note: the suffixes (e.g. 'ssim' for 'exploded_tag' in the above example) can't have underscores, otherwise things break.
      def prefix
        @prefix ||= field_name.gsub("#{DELIMETER}#{field_name.split(/#{DELIMETER}/).last}", '')
      end


      delegate :blacklight_config, to: :helpers

      def facet_tree
        @facet_tree ||= {}
        return @facet_tree[prefix] unless @facet_tree[prefix].nil?
        return @facet_tree[prefix] unless blacklight_config.facet_display[:hierarchy] && blacklight_config.facet_display[:hierarchy][prefix]
        @facet_tree[prefix] = {}
        facet_config = blacklight_config.facet_display[:hierarchy][prefix]
        split_regex = Regexp.new("\s*#{Regexp.escape(facet_config.length >= 2 ? facet_config[1] : ':')}\s*")
        facet_config.first.each do |key|
          # TODO: remove baked in notion of underscores being part of the blacklight facet field names
          facet_field = [prefix, key].compact.join('_')
          @facet_tree[prefix][facet_field] ||= {}
          data = @facet_field.display_facet
          next if data.nil?
          data.items.each do |facet_item|
            path = facet_item.value.split(split_regex)
            loc = @facet_tree[prefix][facet_field]
            loc = loc[path.shift] ||= {} while path.length > 0
            loc[:_] = HierarchicalFacetItem.new(facet_item.value, facet_item.value.split(split_regex).last, facet_item.hits)
          end
        end
        @facet_tree[prefix]
      end
    end
  end
end
