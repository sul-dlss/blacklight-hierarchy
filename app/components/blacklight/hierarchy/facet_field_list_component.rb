# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class FacetFieldListComponent < Blacklight::FacetFieldListComponent
      def render_hierarchy
        helpers.render_hierarchy(@facet_field.facet_field)
      end
    end
  end
end
