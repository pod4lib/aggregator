# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups' do
  before do
    sign_in create(:admin)
  end

  let(:valid_attributes) do
    { name: 'Test Group', short_name: 'Test', slug: 'test-group' }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Group.create! valid_attributes
      get groups_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      group = Group.create! valid_attributes
      get group_url(group)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_group_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      group = Group.create! valid_attributes
      get edit_group_url(group)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    it 'creates a new Group' do
      expect do
        post groups_url, params: { group: valid_attributes }
      end.to change(Group, :count).by(1)
    end

    it 'redirects to the created group' do
      post groups_url, params: { group: valid_attributes }
      expect(response).to redirect_to(group_url(Group.last))
    end
  end

  describe 'PATCH /update' do
    let(:group) { Group.create! valid_attributes }
    let(:new_attributes) do
      { name: 'Updated Group Name' }
    end

    it 'updates the requested group' do
      patch group_url(group), params: { group: new_attributes }
      group.reload
      expect(group.name).to eq('Updated Group Name')
    end

    it 'redirects to the group' do
      patch group_url(group), params: { group: new_attributes }
      expect(response).to redirect_to(group_url(group))
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested group' do
      group = Group.create! valid_attributes
      expect do
        delete group_url(group)
      end.to change(Group, :count).by(-1)
    end

    it 'redirects to the groups list' do
      group = Group.create! valid_attributes
      delete group_url(group)
      expect(response).to redirect_to(groups_url)
    end
  end
end
