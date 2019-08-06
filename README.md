# Blacklight::Hierarchy
[![Build Status](https://travis-ci.org/sul-dlss/blacklight-hierarchy.svg?branch=master)](https://travis-ci.org/sul-dlss/blacklight-hierarchy) [![Coverage Status](https://coveralls.io/repos/sul-dlss/blacklight-hierarchy/badge.png)](https://coveralls.io/r/sul-dlss/blacklight-hierarchy) [![Gem Version](https://badge.fury.io/rb/blacklight-hierarchy.svg)](http://badge.fury.io/rb/blacklight-hierarchy)

This plugin provides hierarchical facets for [Blacklight](https://github.com/projectblacklight/blacklight).

Please note this is does not directly follow any of the competing approaches of [Hierarchical Facets in Solr](http://wiki.apache.org/solr/HierarchicalFaceting), including Solr PivotFacets.

## Usage

Add the plugin to your Blacklight app's Gemfile.

```ruby
gem 'blacklight-hierarchy'
```

Index your hierarchies in a (colon-)separated list. For example, items in a "processing" queue with a "copy" action, might be indexed as:

```xml
<doc>
  <field name="id">foo</field>
  <field name="queue_status_facet">processing</field>
  <field name="queue_status_facet">processing:copy</field>
  <field name="queue_status_facet">processing:copy:waiting</field>
</doc>
<doc>
  <field name="id">bar</field>
  <field name="queue_status_facet">processing</field>
  <field name="queue_status_facet">processing:copy</field>
  <field name="queue_status_facet">processing:copy:completed</field>
</doc>
```

That would cause the facet count to appear at all three levels:

- [processing](#) (2)
    - [copy](#) (2)
        - [completed](#) (1)
        - [waiting](#) (1)

You can skip as many levels as you'd like, as long as the "leaf" values are indexed. For example, if you didn't index the "processing" part alone, it will simply be a container, not a clickable/countable facet:

- processing
    - [copy](#) (2)
        - [completed](#) (1)
        - [waiting](#) (1)

**Note**: If you use Solr's built-in [PathHierarchyTokenizerFactory](http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.PathHierarchyTokenizerFactory), you can index the entire depth by supplying only the leaf nodes.  Otherwise you are expected to build the permutations yourself before loading.

In your Blacklight controller configuration (usually `CatalogController`), tell Blacklight to render the facet using the hierarchy partial.


```ruby
config.add_facet_field 'queue_wps',   :label => 'Queue Status', :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'queue_wsp',   :label => 'Queue Status', :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'queue_swp',   :label => 'Queue Status', :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'callnum_top', :label => 'Callnumber',   :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'foo_trunk',   :label => 'Foo L1',       :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'foo_branch',  :label => 'Foo L2',       :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'foo_leaves',  :label => 'Foo L3',       :partial => 'blacklight/hierarchy/facet_hierarchy'
config.add_facet_field 'tag_facet',   :label => 'Tag',          :partial => 'blacklight/hierarchy/facet_hierarchy'
```

Add your hierarchy-specific options to the controller configuration:

```ruby
config.facet_display = {
  :hierarchy => {
    'queue'   => [['wps','wsp','swp'], ':'],       # values are arrays: 1st element is array, 2nd is delimiter string
    'callnum' => [['top'], '/'],
    'foo'     => [['trunk', 'branch', 'leaves']],  # implied default delimiter
    'tag'     => [[nil]]                           # TODO: explain
  }
}
```

In the above configuration, 'queue_status_facet' is the full Solr field name, and ':' is the delimiter within the field.  Note that suffixes ('facet' in the above example) should not contain underscores, since the methods that deal with the Solr fields and match them to the config assume the "prefix" ('queue_status' in the above example) will be everything up to the last underscore in the field name.  See the facet_tree method for further explanation and some relevant code, as well as the render_hierarchy method for relevant code.

The `[nil]` value is present in support of rotatable facet hierarchies, a totally undocumented feature.

Facet fields should be added for each permutation of hierarchy key and term values, joined by **_**.  Or, the output of:

```ruby
config.facet_display[:hierarchy].each{ |k,v| puts "#{k}_#{v}" }
```

## Caveats

This code was ripped out of another project, and is still quite immature as a standalone project. Every effort has been made to make it as plug-and-play as possible, but it may stomp on Blacklight in unintended ways (e.g., ways that made sense in context of its former host app, but which aren't compatible with generic Blacklight). Proceed with caution, and report issues.

## TODO

- WRITE TESTS
- Switch internal facet management from hack-y Hash to `Blacklight::Hierarchy::FacetGroup` class (already implemented, but not plumbed up)
- Add configuration support for hierarchy delimiters other than `/\s*:\s*/` (baked into `Blacklight::Hierarchy::FacetGroup`, but again, requiring additional plumbing)
- Clarify when suffix is applied/required/etc.
