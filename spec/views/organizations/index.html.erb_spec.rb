# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  before do
    assign(:organizations, [
             Organization.create!(
               name: 'Name1',
               slug: 'Slug1'
             ),
             Organization.create!(
               name: 'Name2',
               slug: 'Slug2'
             )
           ])
  end

  it 'renders a list of organizations' do
    render
    assert_select 'tr>td', text: 'Name1'.to_s
  end
end
