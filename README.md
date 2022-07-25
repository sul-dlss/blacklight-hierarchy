# Blacklight::Hierarchy
[![Build Status](https://github.com/sul-dlss/blacklight-hierarchy/workflows/CI/badge.svg)](https://github.com/sul-dlss/blacklight-hierarchy/actions?query=branch%3Amain) [![Coverage Status](https://coveralls.io/repos/sul-dlss/blacklight-hierarchy/badge.png)](https://coveralls.io/r/sul-dlss/blacklight-hierarchy) [![Gem Version](https://badge.fury.io/rb/blacklight-hierarchy.svg)](http://badge.fury.io/rb/blacklight-hierarchy)

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

In your Blacklight controller configuration (usually `CatalogController`), tell Blacklight to render the facet using the hierarchy component.


```ruby
config.add_facet_field 'queue_wps',   label: 'Queue Status', component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'queue_wsp',   label: 'Queue Status', component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'queue_swp',   label: 'Queue Status', component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'callnum_top', label: 'Callnumber',   component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'foo_trunk',   label: 'Foo L1',       component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'foo_branch',  label: 'Foo L2',       component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'foo_leaves',  label: 'Foo L3',       component: Blacklight::Hierarchy::FacetFieldListComponent
config.add_facet_field 'tag_facet',   label: 'Tag',          component: Blacklight::Hierarchy::FacetFieldListComponent
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

### Changing the icons
We store our closed/open icons as the SASS variables `$b-h-closed-icon` and `$b-h-closed-icon` in `hierarchy.scss`. By default we use SVGs provided by the [Font Awesome](https://github.com/FortAwesome/Font-Awesome) library. To change the icon, reassign these SASS variables with new SVG code.

```scss
  /* app/assets/stylesheets/blacklight/hierarchy/hierarchy.scss */

  // plus sign
  $b-h-closed-icon: url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 448 512'><!--! Font Awesome Free 6.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. --><path d='M200 344V280H136C122.7 280 112 269.3 112 256C112 242.7 122.7 232 136 232H200V168C200 154.7 210.7 144 224 144C237.3 144 248 154.7 248 168V232H312C325.3 232 336 242.7 336 256C336 269.3 325.3 280 312 280H248V344C248 357.3 237.3 368 224 368C210.7 368 200 357.3 200 344zM0 96C0 60.65 28.65 32 64 32H384C419.3 32 448 60.65 448 96V416C448 451.3 419.3 480 384 480H64C28.65 480 0 451.3 0 416V96zM48 96V416C48 424.8 55.16 432 64 432H384C392.8 432 400 424.8 400 416V96C400 87.16 392.8 80 384 80H64C55.16 80 48 87.16 48 96z'/></svg>") !default;
```


### Aria Labels
For screen reader purposes we have used "Toggle subgroup" as the aria-label attribute of the button.  This is internationalized using rails' i18n feature.

The field name is used in the key to allow for facet specific aria labels or defaults back to the generic key/"Toggle subgroup" text.

```yml
# config/locales/en.yml
en:
  blacklight:
    hierarchy:
      format_ssim_toggle_aria_label: Toggle format section
      toggle_aria_label: Toggle call number section
```

### Javascript

The javascript in this project requires jquery, but it's up to you to provide it in a way that best works for your project.  You may consider the jquery-rails gem or if you use webpacker, you could use the jquery npm package.

## Caveats

This code was ripped out of another project, and is still quite immature as a standalone project. Every effort has been made to make it as plug-and-play as possible, but it may stomp on Blacklight in unintended ways (e.g., ways that made sense in context of its former host app, but which aren't compatible with generic Blacklight). Proceed with caution, and report issues.

## Release

In order to cut a new release you will need to publish simultaneously to NPM and RubyGems. Before you do that ensure that versions in `lib/blacklight/hierarchy/version.rb` and `package.json` match. Assuming you have the credentials to do it you can then:

```
$ rake release
$ npm publish
```

## TODO

- WRITE TESTS
- Switch internal facet management from hack-y Hash to `Blacklight::Hierarchy::FacetGroup` class (already implemented, but not plumbed up)
- Clarify when suffix is applied/required/etc.
