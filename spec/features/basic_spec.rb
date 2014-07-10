require 'spec_helper'

describe "catalog" do

  # FIXME:  need to get css organized for engine_cart so the tests will pass.

  before(:each) do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
#      config.add_facet_field 'rotate_tag_facet', :label => 'Tag', :partial => 'blacklight/hierarchy/facet_hierarchy'
      config.add_facet_field 'tag_facet', :label => 'Tag', :partial => 'blacklight/hierarchy/facet_hierarchy'
      config.facet_display = {
        :hierarchy => {
#          'rotate' => ['tag'], # this would work if config.add_facet_field was called rotate_tag_facet, instead of tag_facet, I think.  
          'tag' => ['facet']  # stupidly, the facet field is expected to have an underscore followed by SOMETHING;  in this case it is "facet"
        }
      }
    end
    
    @solr_facet_resp = {'responseHeader'=>{'status'=>0, 'QTime'=>4, 'params'=>{'wt'=>'ruby','rows'=>'0'}},
                        'response'=>{'numFound'=>30, 'start'=>0, 'maxScore'=>1.0, 'docs' => [{'id' => '1', 'title_display'=>'title'}]},
                                    'facet_counts' => {
                                      'facet_queries' => {},
                                      'facet_fields' => {
                                        'tag_facet' => [
                                            'a:b:c', 30,
                                            'a:b:d', 25, 
                                            'a:c:d', 5, 
                                            'p:r:q', 25, 
                                            'x:y', 5, 
                                            'n', 1 ] }, 
                                      'facet_dates' => {},
                                      'facet_ranges' => {}
                                    }
                        }
    rsolr_client = double("rsolr_client")
    expect(rsolr_client).to receive(:send_and_receive).and_return @solr_facet_resp
    expect(RSolr).to receive(:connect).and_return rsolr_client
  end
  
  it "should display the hierarchy" do
    visit '/'
    expect(page).to have_selector('li.h-node', :text => 'a')
    expect(page).to have_selector('li.h-node > ul > li.h-node', :text => 'b')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'c 30')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'd 25')
    expect(page).to have_selector('li.h-node > ul > li.h-node', :text => 'c')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'd 5')
    expect(page).to have_selector('li.h-node', :text => 'p')
    expect(page).to have_selector('li.h-node > ul > li.h-node', :text => 'r')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'q 25')
    expect(page).to have_selector('li.h-node', :text => 'x')
    expect(page).to have_selector('li.h-node li.h-leaf', :text => 'y 5')
    expect(page).to have_selector('.facet-hierarchy > li.h-leaf', :text => 'n 1')
  end

  it "should properly link the hierarchy", :wip => true do
    visit '/'
    expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(catalog_index_path('f' => { 'tag_facet' => ['n'] }))
    expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(catalog_index_path('f' => { 'tag_facet' => ['a:b:c'] }))
    expect(page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }).to include(catalog_index_path('f' => { 'tag_facet' => ['x:y'] }))
  end
end




