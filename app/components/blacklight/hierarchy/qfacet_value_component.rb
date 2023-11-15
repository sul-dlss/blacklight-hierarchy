# frozen_string_literal: true

module Blacklight
  module Hierarchy
    class QfacetValueComponent < ::ViewComponent::Base
      def initialize(field_name:, item:, id: nil, suppress_link: false)
        @field_name = field_name
        @item = item
        @id = id
        @suppress_link = suppress_link
      end

      attr_reader :field_name, :item, :id, :suppress_link

      def path_for_facet
        facet_config = helpers.facet_configuration_for_field(field_name)
        presenter_class = if helpers.search_state.has_constraints?
           Blacklight::FacetItemPresenter
        else
          # Bypasses slow Blacklight machinery for empty search state.
          # Aprox 3X faster in test with large facet.
          FastFacetItemPresenter
        end
        presenter_class.new(item.qvalue, facet_config, helpers, field_name).href
      end

      def render_facet_count
        classes = "facet-count"
        content_tag("span", t('blacklight.search.facets.count', number: number_with_delimiter(item.hits)), class: classes)
      end
    end
  end
end
