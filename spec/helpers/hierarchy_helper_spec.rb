require 'spec_helper'

describe Blacklight::HierarchyHelper do
  describe '#render_hierarchy' do
    it 'should remove the _suffix from the field name' do
      field = OpenStruct.new(field: 'the_field_name_facet')
      expect(helper).to receive(:facet_tree).with('the_field_name').and_return({})
      helper.render_hierarchy(field)
    end
  end
end
