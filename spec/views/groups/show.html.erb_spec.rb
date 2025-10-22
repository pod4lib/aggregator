# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'groups/show' do
  let(:group) { create(:group_with_organizations) }

  before do
    assign(:group, group)
    sign_in create(:admin)
    render
  end

  it 'renders the group name and other details' do
    expect(rendered).to have_css('h1', text: 'A group of organizations')
    expect(rendered).to have_css('dd', text: 'group-')
  end

  it 'renders the organizations list' do
    expect(rendered).to have_css('dt', text: 'Member organizations')
    expect(rendered).to have_css('li', text: 'Organization', count: 3)
  end

  it 'renders the edit button' do
    expect(rendered).to have_link('Edit', href: edit_group_path(group))
  end
end
