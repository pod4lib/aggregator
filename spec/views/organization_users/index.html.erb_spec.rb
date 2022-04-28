# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organization_users/index', type: :view do
  let(:organization) { create(:organization) }
  let(:member) { create(:user) }
  let(:owner) { create(:user) }

  before do
    member.add_role :member, organization
    owner.add_role :owner, organization
    assign(:organization, organization)
  end

  it 'renders a list of users' do
    render
    assert_select 'tr>td', text: member.email
    assert_select 'tr>td', text: owner.email
  end

  context 'when the user is a member' do
    before do
      sign_in member
    end

    it 'renders the role of each user' do
      render
      assert_select 'tr>td', text: 'Member'
      assert_select 'tr>td', text: 'Owner'
    end
  end

  context 'when the user is an owner' do
    before do
      sign_in owner
    end

    it 'renders a link to add the owner role to the member' do
      render
      expect(rendered).to have_link('', href: organization_user_path(organization, member, add_role: 'owner'))
    end

    it 'renders a link to remove the owner role from the owner' do
      render
      expect(rendered).to have_link('', href: organization_user_path(organization, owner, remove_role: 'owner'))
    end

    it 'renders a link to delete the member account' do
      render
      expect(rendered).to have_css("a[href='#{organization_user_path(organization, member)}'][data-method='delete']")
    end

    it 'renders a link to delete the owner account' do
      render
      expect(rendered).to have_css("a[href='#{organization_user_path(organization, owner)}'][data-method='delete']")
    end

    it 'renders a link to invite new user' do
      render
      expect(rendered).to have_link 'Invite new user to organization'
    end
  end

  context 'when a user has both member and owner roles' do
    before do
      member.add_role :owner, organization
    end

    it 'only displays user once in the table' do
      render
      assert_select 'tr>td', text: member.email, count: 1
    end
  end
end
