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
  context 'with only valid items' do
    let(:items) do
      [
        Blacklight::Solr::Response::Facets::FacetItem.new(label: 'A - General Works', value: 'A - General Works', hits: 5),
        Blacklight::Solr::Response::Facets::FacetItem.new(label: 'A - General Works:AC - Collections Works', value: 'A - General Works:AC - Collections Works', hits: 4)
      ]
    end
    it 'creates HierarchicalFacetItems' do
      facet_tree = described_class.build(prefix:, facet_display:, facet_field:)
      expect(facet_tree['lc_facet'].size).to eq(1)
      expect(facet_tree['lc_facet'].keys.first).to eq('A - General Works')
      expect(facet_tree['lc_facet']['A - General Works'].keys).to match_array([:_, 'AC - Collections Works'])
      expect(facet_tree['lc_facet']['A - General Works'][:_]).to be_an_instance_of(HierarchicalFacetItem)
    end
  end


  context 'with an invalid item' do
    let(:items) do
      [
        Blacklight::Solr::Response::Facets::FacetItem.new(label: ':', value: ':', hits: 100),
        Blacklight::Solr::Response::Facets::FacetItem.new(label: 'A - General Works', value: 'A - General Works', hits: 5),
        Blacklight::Solr::Response::Facets::FacetItem.new(label: 'A - General Works:AC - Collections Works', value: 'A - General Works:AC - Collections Works', hits: 4)
      ]
    end

    it 'raises an error' do
      expect do
        described_class.build(prefix:, facet_display:, facet_field:)
      end.to raise_error(StandardError, "Expected non-empty array after splitting facet value. Original facet value: ':'")
    end
  end

end
