# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/provider_details', type: :view do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:admin) { create(:admin) }

  before do
    assign(:organization, organization)
  end

  # rubocop:disable RSpec/ExampleLength
  it 'renders form with fields for normalization' do
    # this part of the view is seen by org owners and admins
    allow(view).to receive(:can?).and_return(true)
    render
    assert_select 'form[action=?][method=?]', organization_path(organization), 'post' do
      assert_select 'input[name=?]', 'organization[marc_docs_url]'
      assert_select 'input[name=?]', 'organization[normalization_steps[0][subfields][i]]'
      assert_select 'input[name=?]', 'organization[normalization_steps[0][subfields][a]]'
      assert_select 'input[name=?]', 'organization[normalization_steps[0][subfields][m]]'
    end
  end
  # rubocop:enable RSpec/ExampleLength

  it 'renders a <dl> description list with 4 <dt> description terms' do
    # this part of the view is seen by org memebers
    render

    assert_select 'dl dt', 5
  end
end
