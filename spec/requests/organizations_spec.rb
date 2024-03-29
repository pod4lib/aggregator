# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/organizations' do
  before do
    sign_in create(:admin)
  end

  # Organization. As you add validations to Organization, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { name: 'Test Org', slug: 'test-org' }
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Organization.create! valid_attributes
      get organizations_url
      expect(response).to be_successful
    end
  end

  describe '/resourcelist' do
    before do
      create(:organization)
      create(:organization)
    end

    it 'has some ResourceSync stuff in it' do
      get resourcelist_organizations_url
      expect(response.body).to include('<rs:md capability="resourcelist"')
        .and(include(resourcelist_organization_stream_url(Organization.first, Organization.first.default_stream)))
        .and(include(resourcelist_organization_stream_url(Organization.last, Organization.last.default_stream)))
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      organization = Organization.create! valid_attributes
      get organization_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_organization_url
      expect(response).to be_successful
    end
  end

  describe 'GET /organization_details' do
    it 'render a successful response' do
      organization = Organization.create! valid_attributes
      get organization_details_organization_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'GET /provider_details' do
    it 'render a successful response' do
      organization = Organization.create! valid_attributes
      get provider_details_organization_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Organization' do
        expect do
          post organizations_url, params: { organization: valid_attributes }
        end.to change(Organization, :count).by(1)
      end

      it 'redirects to the created organization' do
        post organizations_url, params: { organization: valid_attributes }
        expect(response).to redirect_to(organization_url(Organization.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Organization' do
        expect do
          post organizations_url, params: { organization: invalid_attributes }
        end.not_to change(Organization, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post organizations_url, params: { organization: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    let(:organization) { Organization.create! valid_attributes }

    context 'with valid parameters' do
      let(:new_attributes) do
        { name: 'Updated org name' }
      end

      it 'updates the requested organization' do
        patch organization_url(organization), params: { organization: new_attributes }
        organization.reload
        expect(organization).to have_attributes name: 'Updated org name'
      end

      it 'accepts an icon upload' do
        icon = fixture_file_upload(Rails.root.join('spec/fixtures/pod_logo.svg'), 'image/svg+xml')

        expect(organization.icon.attached?).to be false
        patch organization_url(organization), params: { organization: new_attributes.merge(icon: icon) }
        expect(organization.reload.icon.attached?).to be true
      end

      it 'redirects to the organization' do
        organization = Organization.create! valid_attributes
        patch organization_url(organization), params: { organization: new_attributes }
        organization.reload
        expect(response).to redirect_to(organization_url(organization))
      end
    end

    context 'with mapping parameters' do
      let(:new_attributes) do
        { normalization_steps: [{ destination_tag: '999', source_tag: 'PRT', subfields: { i: 'a', a: 'b', m: 'c' } }] }
      end

      it 'updates the requested organization' do
        patch organization_url(organization), params: { organization: new_attributes }
        expect(organization.reload).to have_attributes normalization_steps: [
          hash_including('destination_tag' => '999', 'source_tag' => 'PRT',
                         'subfields' => { 'i' => 'a', 'a' => 'b', 'm' => 'c' })
        ]
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        patch organization_url(organization), params: { organization: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested organization' do
      organization = Organization.create! valid_attributes
      expect do
        delete organization_url(organization)
      end.to change(Organization, :count).by(-1)
    end

    it 'redirects to the organizations list' do
      organization = Organization.create! valid_attributes
      delete organization_url(organization)
      expect(response).to redirect_to(organizations_url)
    end
  end
end
