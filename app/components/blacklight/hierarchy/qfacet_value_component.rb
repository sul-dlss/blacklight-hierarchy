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

      def label_value
        return item.value if facet_item_presenter_class == Blacklight::FacetItemPresenter
        facet_item_presenter_class.new(item.qvalue, facet_config, helpers, field_name).label
      end

      def path_for_facet
        facet_item_presenter_class.new(item.qvalue, facet_config, helpers, field_name).href
      end

      def render_facet_count
        classes = "facet-count"
        content_tag("span", t('blacklight.search.facets.count', number: number_with_delimiter(item.hits)), class: classes)
      end

      def facet_config
        helpers.facet_configuration_for_field(field_name)
      end

      def hierarchy_config
        helpers.blacklight_config.facet_display[:hierarchy]
      end

      def field_name_prefix
        @field_name_prefix ||= field_name.gsub("_#{field_name.split(/_/).last}", '')
      end

      def facet_item_presenter_class
        hierarchy_config.dig(field_name_prefix)[2] || Blacklight::FacetItemPresenter
      end
    end
  end
end
