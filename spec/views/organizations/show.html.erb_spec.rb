# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/show', type: :view do
  before do
    @organization = assign(:organization, Organization.create!(
                                            name: 'Name',
                                            slug: 'Slug'
                                          ))
    sign_in create(:admin)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/).and(match(/Slug/))
  end
end
