# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class FacetFieldListComponent < Blacklight::FacetFieldListComponent
      DELIMETER = '_'

      # @param [Blacklight::Configuration::FacetField] as defined in controller with config.add_facet_field (and with :partial => 'blacklight/hierarchy/facet_hierarchy')
      # @return [String] html for the facet tree
      def tree

        @tree ||= begin
          facet_tree_for_prefix = FacetTree.build(prefix: prefix,
                                                  facet_display: blacklight_config.facet_display,
                                                  facet_field: @facet_field)
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
    end
  end
end
