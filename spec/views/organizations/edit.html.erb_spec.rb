# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/edit', type: :view do
  let(:organization) do
    Organization.create!(
      name: 'MyString',
      slug: 'MyString'
    )
  end

  before do
    assign(:organization, organization)
  end

  it 'renders the edit organization form' do
    render

    assert_select 'form[action=?][method=?]', organization_path(organization), 'post' do
      assert_select 'input[name=?]', 'organization[name]'

      assert_select 'input[name=?]', 'organization[slug]'
    end
  end
end
