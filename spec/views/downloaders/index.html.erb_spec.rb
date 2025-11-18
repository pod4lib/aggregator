# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'downloaders/index' do
  let(:organization) { create(:organization) }
  let(:owner) { create(:user) }

  before do
    owner.add_role :owner, organization
    assign(:organization, organization)
    assign(:other_organizations, create_list(:organization, 2))
    assign(:groups, create_list(:group, 2))
  end

  it 'renders a heading' do
    render
    expect(rendered).to have_css('h3', text: 'Access restrictions')
  end

  context 'when the user is an owner' do
    before do
      allow(Settings).to receive(:allow_organization_owners_to_manage_access).and_return(true)
      sign_in owner
      render
    end

    it 'renders a submit button to update access restrictions' do
      expect(rendered).to have_button('Update download access policy')
    end

    it 'renders a component to manage group access' do
      expect(rendered).to have_css('h5', text: 'Manage group access')
    end

    it 'renders a component to manage organization access' do
      expect(rendered).to have_css('h5', text: 'Manage organization access')
    end
  end
end
