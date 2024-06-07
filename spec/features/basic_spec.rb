# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Basic feature specs', type: :feature do
  let(:solr_facet_resp) do
    { 'responseHeader' => { 'status' => 0, 'QTime' => 4, 'params' => { 'wt' => 'ruby', 'rows' => '0' } },
      'response' => { 'numFound' => 30, 'start' => 0, 'maxScore' => 1.0, 'docs' => [] },
      'facet_counts' => {
        'facet_queries' => {},
        'facet_fields' => {
          'tag_facet' => [
            'a:b:c', 30,
            'a:b:d', 25,
            'a:c:d', 5,
            'p:r:q', 25,
            'x:y', 5,
            'n', 1
          ],
          'my_top_facet' => [
            'f/g/h', 30,
            'j/k', 5,
            'z', 1
          ]
        },
        'facet_dates' => {},
        'facet_ranges' => {}
      } }
  end

  before do
    rsolr_client = instance_double(RSolr::Client, send_and_receive: solr_facet_resp)
    allow(RSolr).to receive(:connect).and_return rsolr_client
  end

  shared_examples 'catalog' do
    context 'facet tree without repeated nodes' do
      it 'displays the hierarchy' do
        visit '/'
        expect(page).to have_selector('li.h-node[data-controller="b-h-collapsible"]', text: 'a')
        expect(page).to have_selector('li.h-node > ul > li.h-node[data-controller="b-h-collapsible"]', text: 'b')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'c 30')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'd 25')
        expect(page).to have_selector('li.h-node > ul > li.h-node', text: 'c')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'd 5')
        expect(page).to have_selector('li.h-node', text: 'p')
        expect(page).to have_selector('li.h-node > ul > li.h-node', text: 'r')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'q 25')
        expect(page).to have_selector('li.h-node', text: 'x')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'y 5')
        expect(page).to have_selector('.facet-hierarchy > li.h-leaf', text: 'n 1')
      end

      it 'properly links the hierarchy' do
        visit '/'
        expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(root_path('f' => { 'tag_facet' => ['n'] }))
        expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(root_path('f' => { 'tag_facet' => ['a:b:c'] }))
        expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(root_path('f' => { 'tag_facet' => ['x:y'] }))
      end

      it 'works with a different value delimiter' do
        visit '/'
        expect(page).to have_selector('li.h-node', text: 'f')
        expect(page).to have_selector('li.h-node > ul > li.h-node', text: 'g')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'h 30')
        expect(page).to have_selector('li.h-node', text: 'j')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'k 5')
        expect(page).to have_selector('.facet-hierarchy > li.h-leaf', text: 'z 1')
      end
    end

    context 'facet tree with repeated nodes' do
      let(:solr_facet_resp) do
        { 'responseHeader' => { 'status' => 0, 'QTime' => 4, 'params' => { 'wt' => 'ruby', 'rows' => '0' } },
          'response' => { 'numFound' => 30, 'start' => 0, 'maxScore' => 1.0, 'docs' => [] },
          'facet_counts' => {
            'facet_queries' => {},
            'facet_fields' => {
              'tag_facet' => [
                'm:w:w:t', 15,
                'm:w:v:z', 10
              ]
            },
            'facet_dates' => {},
            'facet_ranges' => {}
          } }
      end
      it 'displays all child nodes when a node value is repeated at its child level' do
        visit '/'
        expect(page).to have_selector('li.h-node', text: 'm')
        expect(page).to have_selector('li.h-node > ul > li.h-node', text: 'w')
        expect(page).to have_selector('li.h-node > ul > li.h-node > ul > li.h-node', text: 'w')
        expect(page).to have_selector('li.h-node > ul > li.h-node > ul > li.h-node', text: 'v')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 't 15')
        expect(page).to have_selector('li.h-node li.h-leaf', text: 'z 10')
      end
    end
  end

  describe 'config_1' do
    it_behaves_like 'catalog' do
      before do
        CatalogController.blacklight_config = Blacklight::Configuration.new
        CatalogController.configure_blacklight do |config|
          config.add_facet_field 'tag_facet',    label: 'Tag',         component: Blacklight::Hierarchy::FacetFieldListComponent
          config.add_facet_field 'my_top_facet', label: 'Slash Delim', component: Blacklight::Hierarchy::FacetFieldListComponent
          config.facet_display = {
            hierarchy: {
              'tag' => [['facet'], ':'], # stupidly, the facet field is expected to have an underscore followed by SOMETHING;  in this case it is "facet"
              'my_top' => [['facet'], '/']
            }
          }
        end
      end
    end
  end

  describe 'config_2' do
    it_behaves_like 'catalog' do
      before do
        CatalogController.blacklight_config = Blacklight::Configuration.new
        CatalogController.configure_blacklight do |config|
          config.add_facet_field 'tag_facet',    label: 'Tag',         component: Blacklight::Hierarchy::FacetFieldListComponent
          config.add_facet_field 'my_top_facet', label: 'Slash Delim', component: Blacklight::Hierarchy::FacetFieldListComponent
          config.facet_display = {
            hierarchy: {
              'tag' => [['facet']], # rely on default delim
              'my_top' => [['facet'], '/']
            }
          }
        end
      end
    end
  end

  describe 'configure labels via a custom FacetItemPresenter' do
    before do
      class MyCustomFacetItemPresenter < Blacklight::FacetItemPresenter
        def label
          # Derive a custom label from the original value
          value.upcase
        end
      end

      CatalogController.blacklight_config = Blacklight::Configuration.new
      CatalogController.configure_blacklight do |config|
        config.add_facet_field 'tag_facet', label: 'Tag', component: Blacklight::Hierarchy::FacetFieldListComponent
        config.facet_display = {
          hierarchy: {
            'tag' => [['facet'], ':', MyCustomFacetItemPresenter] # configure a custom presenter
          }
        }
      end
    end

    it 'uses custom labels for the facet items' do
      visit '/'
      expect(page).to have_selector('li.h-node li.h-leaf', text: 'A:B:C 30')
      expect(page).to have_selector('li.h-node li.h-leaf', text: 'A:B:D 25')
      expect(page).to have_selector('li.h-node li.h-leaf', text: 'A:C:D 5')
    end
  end

  describe 'Item sort determined by existing add_facet_field config' do
    context 'with alpha sort' do
      before do
        CatalogController.blacklight_config = Blacklight::Configuration.new
        CatalogController.configure_blacklight do |config|
          config.add_facet_field 'tag_facet', sort: 'alpha', label: 'Tag', component: Blacklight::Hierarchy::FacetFieldListComponent
          config.facet_display = {
            hierarchy: {
              'tag' => [['facet'], ':']
            }
          }
        end
      end

      # Note that sort: 'alpha' in the add_facet_field config will sort the facets in the response;
      # This is the order in which they will render in the facet tree.
      let(:solr_facet_resp) do
        { 'responseHeader' => { 'status' => 0, 'QTime' => 4, 'params' => { 'wt' => 'ruby', 'rows' => '0' } },
          'response' => { 'numFound' => 30, 'start' => 0, 'maxScore' => 1.0, 'docs' => [] },
          'facet_counts' => {
            'facet_queries' => {},
            'facet_fields' => {
              'tag_facet' => [
                'a', 100,
                'a:b', 80,
                'a:b:c', 70,
                'a:b:d', 9,
                'a:b:e', 1,
                'a:f', 20,
                'g', 200,
                'g:h', 50,
                'g:i', 150
              ]
            },
            'facet_dates' => {},
            'facet_ranges' => {}
          } }
      end

      it 'sorts the facet items alphabetically' do
        visit '/'
        facet_text = first('.facet-hierarchy').text.squish
        expect(facet_text).to eq('a 100 b 80 c 70 d 9 e 1 f 20 g 200 h 50 i 150')
      end
    end

    context 'with count sort' do
      before do
        CatalogController.blacklight_config = Blacklight::Configuration.new
        CatalogController.configure_blacklight do |config|
          config.add_facet_field 'tag_facet', sort: 'count', label: 'Tag', component: Blacklight::Hierarchy::FacetFieldListComponent
          config.facet_display = {
            hierarchy: {
              'tag' => [['facet'], ':']
            }
          }
        end
      end

      # Note that sort: 'count' in the add_facet_field config (default) will sort the facets in the response;
      # This is the order in which they will render in the facet tree.
      let(:solr_facet_resp) do
        { 'responseHeader' => { 'status' => 0, 'QTime' => 4, 'params' => { 'wt' => 'ruby', 'rows' => '0' } },
          'response' => { 'numFound' => 30, 'start' => 0, 'maxScore' => 1.0, 'docs' => [] },
          'facet_counts' => {
            'facet_queries' => {},
            'facet_fields' => {
              'tag_facet' => [
                'g', 200,
                'g:i', 150,
                'g:h', 50,
                'a', 100,
                'a:b', 80,
                'a:b:c', 70,
                'a:b:d', 9,
                'a:b:e', 1,
                'a:f', 20
              ]
            },
            'facet_dates' => {},
            'facet_ranges' => {}
          } }
      end

      it 'sorts the facet items by count' do
        visit '/'
        facet_text = first('.facet-hierarchy').text.squish
        expect(facet_text).to eq('g 200 i 150 h 50 a 100 b 80 c 70 d 9 e 1 f 20')
      end
    end
  end
end
