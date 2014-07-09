require 'spec_helper'

describe "Facet Hierarchy", :vcr => {:cassette_name => "solr"} do

  before(:each) do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
#      config.index.title_field = 'title_display'
#      config.default_solr_params = {
#        :rows => 10
#      }
      config.add_facet_field 'tag_facet', :label => 'Tag', :partial => 'blacklight/hierarchy/facet_hierarchy'
      config.facet_display = {
        :hierarchy => {
          'tag' => [nil]
        }
      }
      config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    end
  end

  it 'uses the solr cassette' do
    expect(VCR.current_cassette.name).to eql "solr"
  end
  
  it "should display the hierarchy" do
    visit '/'
#p page.source  
    expect(page).to have_selector('li.h-node', :text => 'a')
    expect(page).to have_selector('li.h-node > ul > li.h-node', :text => 'b')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'c (30)')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'd (25)')
    expect(page).to have_selector('li.h-node > ul > li.h-node', :text => 'c')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'd (5)')
    expect(page).to have_selector('.facet-hierarchy > li.h-leaf', :text => 'n (1)')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'q (25)')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'x (5)')
  end

  it "should properly link the hierarchy" do
    visit '/'
#p page.all(:css, 'li.h-leaf a')    
    expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(catalog_index_path('f' => { 'tag_facet' => ['n'] }))
    expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(catalog_index_path('f' => { 'tag_facet' => ['a:b:c'] }))
    expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(catalog_index_path('f' => { 'tag_facet' => ['x:y'] }))
  end
end
