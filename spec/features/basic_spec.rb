require 'spec_helper'

describe "catalog" do

  before(:each) do
    CatalogController.blacklight_config = Blacklight::Configuration.new
    CatalogController.configure_blacklight do |config|
      config.add_facet_field 'tag_facet', :label => 'Tag', :partial => 'blacklight/hierarchy/facet_hierarchy'
      config.facet_display = {
        :hierarchy => {
          'tag' => [nil]
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
#p page.source 
    page.should have_selector('li.h-node', :content => 'a')
    page.should have_selector('li.h-node > ul > li.h-node', :content => 'b')
    page.should have_selector('li.h-node li.h-leaf', :content => 'c (30)')
    page.should have_selector('li.h-node li.h-leaf', :content => 'd (25)')
    page.should have_selector('li.h-node > ul > li.h-node', :content => 'c')
    page.should have_selector('li.h-node li.h-leaf', :content => 'd (5)')
    page.should have_selector('.facet-hierarchy > li.h-leaf', :content => 'n (1)')
    page.should have_selector('li.h-node li.h-leaf', :content => 'q (25)')
    page.should have_selector('li.h-node li.h-leaf', :content => 'x (5)')
  end

  it "should properly link the hierarchy" do
    visit '/'
    page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }.should include(catalog_index_path('f' => { 'tag_facet' => ['n'] }))
    page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }.should include(catalog_index_path('f' => { 'tag_facet' => ['a:b:c'] }))
    page.all(:css, 'li.h-leaf a').map { |a| a[:href].to_s }.should include(catalog_index_path('f' => { 'tag_facet' => ['x:y'] }))
  end
end




