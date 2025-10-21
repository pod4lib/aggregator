# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'groups/index' do
  let(:org_one) { create(:organization, name: 'Organization One', provider: true) }
  let(:org_two) { create(:organization, name: 'Organization Two', provider: true) }
  let(:group_one) { create(:group, name: 'Group One', organizations: [org_one]) }
  let(:group_two) { create(:group, name: 'Group Two') }

  before do
    assign(:groups, [group_one, group_two])
    assign(:organizations, [org_one, org_two])

    sign_in create(:admin)
    render
  end

  it 'renders a table of providers' do
    assert_select 'tr>td', text: 'Group One'
    assert_select 'tr>td', text: 'Group Two'
  end

  it 'renders a table of organizations' do
    assert_select 'tr>td', text: 'Organization One'
    assert_select 'tr>td', text: 'Organization Two'
  end

  it 'renders the membership status' do
    assert_select 'tr>td>span', text: 'Member'
  end

  it 'renders the New group button' do
    assert_select 'a.btn', text: 'New group', href: new_group_path
  end
end
