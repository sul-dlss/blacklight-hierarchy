require 'spec_helper'

RSpec.describe Blacklight::Hierarchy::FacetTree do
  let(:prefix) { 'lc' }
  let(:facet_display) { { hierarchy: { 'lc' => [['facet'], ':'] } } }
  let(:display_facet) do
    instance_double(Blacklight::Solr::Response::Facets::FacetField, name: 'lc_facet', items:, limit: 1001, sort: :index, offset: 0, prefix: nil)
  end
  let(:items) do
    [
      Blacklight::Solr::Response::Facets::FacetItem.new(label: ':', value: ':', hits: 100),
      Blacklight::Solr::Response::Facets::FacetItem.new(label: 'A - General Works', value: 'A - General Works', hits: 5),
      Blacklight::Solr::Response::Facets::FacetItem.new(label: 'A - General Works:AC - Collections Works', value: 'A - General Works:AC - Collections Works', hits: 4)
    ]
  end
  let(:facet_field) do
    instance_double(
      Blacklight::FacetFieldPresenter,
      display_facet:,
      key: 'lc_facet',
      label: 'Classification'
    )
  end
  it 'does not create empty HierarchicalFacetItems' do
    facet_tree = described_class.build(prefix:, facet_display:, facet_field:)
    facet_tree['lc_facet'].each do |_key, value|
      expect(value.dig(:_)&.value).not_to be_nil
    end
    expect(facet_tree['lc_facet'].size).to eq(1)
  end
end
