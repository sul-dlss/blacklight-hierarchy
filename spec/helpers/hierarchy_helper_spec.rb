require 'spec_helper'

RSpec.describe Blacklight::HierarchyHelper do
  describe '#facet_toggle_button' do
    subject { helper.facet_toggle_button(field_name, described_by, 'randomtext123') }
    let(:field_name) { 'exploded_tag_ssim' }
    let(:described_by) { 'unique-string' }

    it { is_expected.to be_html_safe }
  end
end
