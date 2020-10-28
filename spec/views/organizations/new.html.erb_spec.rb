# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/new', type: :view do
  before do
    assign(:organization, Organization.new(
                            name: 'MyString',
                            slug: 'MyString'
                          ))
  end

  it 'renders new organization form' do
    render

    assert_select 'form[action=?][method=?]', organizations_path, 'post' do
      assert_select 'input[name=?]', 'organization[name]'

      assert_select 'input[name=?]', 'organization[slug]'
    end
  end
end
