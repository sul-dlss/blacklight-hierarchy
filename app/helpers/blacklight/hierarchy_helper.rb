module Blacklight::HierarchyHelper
  # Putting bare HTML strings in a helper sucks. But in this case, with a
  # lot of recursive tree-walking going on, it's an order of magnitude faster
  # than either render(:partial) or content_tag
  def render_facet_hierarchy_item(field_name, data, key)
    item = data[:_]
    subset = data.reject { |k, _v| !k.is_a?(String) }

    li_class = subset.empty? ? 'h-leaf' : 'h-node'
    ul = ''
    li = if item.nil?
           key
         elsif facet_in_params?(field_name, item.qvalue)
           render_selected_qfacet_value(field_name, item)
         else
           render_qfacet_value(field_name, item)
         end

    unless subset.empty?
      subul = subset.keys.sort.collect do |subkey|
        render_facet_hierarchy_item(field_name, subset[subkey], subkey)
      end.join('')
      ul = "<ul>#{subul}</ul>".html_safe
    end

    %(<li class="#{li_class}">#{li.html_safe}#{ul.html_safe}</li>).html_safe
  end

  # @param [Blacklight::Configuration::FacetField] as defined in controller with config.add_facet_field (and with :partial => 'blacklight/hierarchy/facet_hierarchy')
  # @return [String] html for the facet tree
  def render_hierarchy(bl_facet_field, delim = '_')
    field_name = bl_facet_field.field
    prefix = field_name.gsub("#{delim}#{field_name.split(/#{delim}/).last}", '')
    facet_tree_for_prefix = facet_tree(prefix)
    tree = facet_tree_for_prefix ? facet_tree_for_prefix[field_name] : nil

    return '' unless tree
    tree.keys.sort.collect do |key|
      render_facet_hierarchy_item(field_name, tree[key], key)
    end.join("\n").html_safe
  end

  def render_qfacet_value(facet_solr_field, item, options = {})
    (link_to_unless(options[:suppress_link], item.value, search_state.add_facet_params(facet_solr_field, item.qvalue), class: 'facet_select') + ' ' + render_facet_count(item.hits)).html_safe
  end

  # Standard display of a SELECTED facet value, no link, special span with class, and 'remove' button.
  def render_selected_qfacet_value(facet_solr_field, item)
    content_tag(:span, render_qfacet_value(facet_solr_field, item, suppress_link: true), class: 'selected') + ' ' +
      link_to(content_tag(:span, '', class: 'glyphicon glyphicon-remove') +
              content_tag(:span, '[remove]', class: 'sr-only'),
              search_state.remove_facet_params(facet_solr_field, item.qvalue),
              class: 'remove'
             )
  end

  HierarchicalFacetItem = Struct.new :qvalue, :value, :hits

  # @param [String] hkey - a key to access the rest of the hierarchy tree, as defined in controller config.facet_display[:hierarchy] declaration.
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
  def facet_tree(hkey)
    @facet_tree ||= {}
    return @facet_tree[hkey] unless @facet_tree[hkey].nil?
    return @facet_tree[hkey] unless blacklight_config.facet_display[:hierarchy] && blacklight_config.facet_display[:hierarchy][hkey]
    @facet_tree[hkey] = {}
    facet_config = blacklight_config.facet_display[:hierarchy][hkey]
    split_regex = Regexp.new("\s*#{Regexp.escape(facet_config.length >= 2 ? facet_config[1] : ':')}\s*")
    facet_config.first.each do |key|
      # TODO: remove baked in notion of underscores being part of the blacklight facet field names
      facet_field = [hkey, key].compact.join('_')
      @facet_tree[hkey][facet_field] ||= {}
      data = @response.aggregations[facet_field]
      next if data.nil?
      data.items.each do |facet_item|
        path = facet_item.value.split(split_regex)
        loc = @facet_tree[hkey][facet_field]
        loc = loc[path.shift] ||= {} while path.length > 0
        loc[:_] = HierarchicalFacetItem.new(facet_item.value, facet_item.value.split(split_regex).last, facet_item.hits)
      end
    end
    @facet_tree[hkey]
  end

  # --------------------------------------------------------------------------------------------------------------------------------
  # below are methods pertaining to the "rotate" notion where you may want to look at the same tree data organized another way
  # --------------------------------------------------------------------------------------------------------------------------------

  # FIXME: remove baked in underscore separator in field name
  def is_hierarchical?(field_name)
    (prefix, order) = field_name.split(/_/, 2)
    (list = blacklight_config.facet_display[:hierarchy][prefix]) && list.include?(order)
  end

  def facet_order(prefix)
    param_name = "#{prefix}_facet_order".to_sym
    params[param_name] || blacklight_config.facet_display[:hierarchy][prefix].first
  end

  def facet_after(prefix, order)
    orders = blacklight_config.facet_display[:hierarchy][prefix]
    orders[orders.index(order) + 1] || orders.first
  end

  # FIXME: remove baked in underscore separator in field name
  def hide_facet?(field_name)
    return false unless is_hierarchical?(field_name)
    prefix = field_name.split(/_/).first
    field_name != "#{prefix}_#{facet_order(prefix)}"
  end

  # FIXME: remove baked in colon separator
  def rotate_facet_value(val, from, to)
    components = Hash[from.split(//).zip(val.split(/:/))]
    new_values = components.values_at(*to.split(//))
    new_values.pop while new_values.last.nil?
    return nil if new_values.include?(nil)
    new_values.compact.join(':')
  end

  # FIXME: remove baked in underscore separator in field name
  def rotate_facet_params(prefix, from, to, p = params.dup)
    return p if from == to
    from_field = "#{prefix}_#{from}"
    to_field = "#{prefix}_#{to}"
    p[:f] = (p[:f] || {}).dup # the command above is not deep in rails3, !@#$!@#$
    p[:f][from_field] = (p[:f][from_field] || []).dup
    p[:f][to_field] = (p[:f][to_field] || []).dup
    p[:f][from_field].reject! { |v| p[:f][to_field] << rotate_facet_value(v, from, to); true }
    p[:f].delete(from_field)
    p[:f][to_field].compact!
    p[:f].delete(to_field) if p[:f][to_field].empty?
    p
  end

  # FIXME: remove baked in underscore separator in field name
  def render_facet_rotate(field_name)
    return unless is_hierarchical?(field_name)
    (prefix, order) = field_name.split(/_/, 2)
    return if blacklight_config.facet_display[:hierarchy][prefix].length < 2
    new_order = facet_after(prefix, order)
    new_params = rotate_facet_params(prefix, order, new_order)
    new_params["#{prefix}_facet_order"] = new_order
    link_to image_tag('icons/rotate.png', title: new_order.upcase).html_safe, new_params, class: 'no-underline'
  end
end
