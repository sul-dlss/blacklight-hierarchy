require 'spec_helper'

shared_examples 'catalog' do
  context 'facet tree without repeated nodes' do
    before do
      solr_facet_resp = { 'responseHeader' => { 'status' => 0, 'QTime' => 4, 'params' => { 'wt' => 'ruby', 'rows' => '0' } },
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
                                'n', 1],
                              'my_top_facet' => [
                                'f/g/h', 30,
                                'j/k', 5,
                                'z', 1]
                            },
                            'facet_dates' => {},
                            'facet_ranges' => {}
                          }
                          }
      rsolr_client = double('rsolr_client')
      expect(rsolr_client).to receive(:send_and_receive).and_return solr_facet_resp
      expect(RSolr).to receive(:connect).and_return rsolr_client
    end

    it 'should display the hierarchy' do
      visit '/'
      expect(page).to have_selector('li.h-node', text: 'a')
      expect(page).to have_selector('li.h-node > ul > li.h-node', text: 'b')
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

    it 'should properly link the hierarchy' do
      visit '/'
      expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(root_path('f' => { 'tag_facet' => ['n'] }))
      expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(root_path('f' => { 'tag_facet' => ['a:b:c'] }))
      expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(root_path('f' => { 'tag_facet' => ['x:y'] }))
    end

    it 'should work with a different value delimiter' do
      visit '/'
      expect(page).to have_selector('li.h-node', text: 'f')
      expect(page).to have_selector('li.h-node > ul > li.h-node', text: 'g')
      expect(page).to have_selector('li.h-node li.h-leaf', text: 'h 30')
      expect(page).to have_selector('li.h-node', text: 'j')
      expect(page).to have_selector('li.h-node li.h-leaf', text: 'k 5')
      expect(page).to have_selector('.facet-hierarchy > li.h-leaf', text: 'z 1')
    end
  end # facet tree without repeated nodes

  context 'facet tree with repeated nodes' do
    before do
      facet_resp = { 'responseHeader' => { 'status' => 0, 'QTime' => 4, 'params' => { 'wt' => 'ruby', 'rows' => '0' } },
                     'response' => { 'numFound' => 30, 'start' => 0, 'maxScore' => 1.0, 'docs' => [] },
                     'facet_counts' => {
                       'facet_queries' => {},
                       'facet_fields' => {
                         'tag_facet' => [
                           'm:w:w:t', 15,
                           'm:w:v:z', 10]
                       },
                       'facet_dates' => {},
                       'facet_ranges' => {}
                     }
                    }
      my_rsolr_client = double('rsolr_client')
      expect(my_rsolr_client).to receive(:send_and_receive).and_return facet_resp
      expect(RSolr).to receive(:connect).and_return my_rsolr_client
    end
    it 'should display all child nodes when a node value is repeated at its child level' do
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
            #       'rotate' => [['tag'  ], ':'], # this would work if config.add_facet_field was called rotate_tag_facet, instead of tag_facet, I think.
            'tag'    => [['facet'], ':'], # stupidly, the facet field is expected to have an underscore followed by SOMETHING;  in this case it is "facet"
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
            'tag'    => [['facet']], # rely on default delim
            'my_top' => [['facet'], '/']
          }
        }
      end
    end
  end
end
