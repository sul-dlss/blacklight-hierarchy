class FastFacetItemPresenter
  attr_reader :facet_item, :facet_config, :view_context, :search_state, :facet_field

  def initialize(facet_item, facet_config, view_context, facet_field)
    @facet_item = facet_item
    @facet_config = facet_config
    @view_context = view_context
    @facet_field = facet_field
  end

  def href
    params = {"f" => {facet_config.key => [facet_item]}}
    view_context.search_action_path(params)
  end
end