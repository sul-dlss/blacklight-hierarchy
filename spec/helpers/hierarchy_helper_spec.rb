require 'spec_helper'

RSpec.describe Blacklight::HierarchyHelper do
  describe '#render_hierarchy' do
    it 'should remove the _suffix from the field name' do
      expect(Deprecation).to receive(:warn)
      field = OpenStruct.new(field: 'the_field_name_facet')
      expect(helper).to receive(:facet_tree).with('the_field_name').and_return({})
      helper.render_hierarchy(field)
    end
  end

  describe '#facet_toggle_button' do
    subject { helper.facet_toggle_button(field_name, described_by) }
    let(:field_name) { 'exploded_tag_ssim' }
    let(:described_by) { 'unique-string' }

    it { is_expected.to be_html_safe }
  end
end
