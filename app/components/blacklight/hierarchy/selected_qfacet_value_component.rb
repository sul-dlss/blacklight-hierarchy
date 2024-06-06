# frozen_string_literal: true

module Blacklight
  module Hierarchy
    # Standard display of a SELECTED facet value, no link, special span with class, and 'remove' button.
    class SelectedQfacetValueComponent < QfacetValueComponent
      def initialize(field_name:, item:)
        @field_name = field_name
        @item = item
      end

      attr_reader :field_name, :item

      def remove_href
        helpers.search_action_path(helpers.search_state.filter(field_name).remove(item.qvalue).params)
      end
    end
  end
end
