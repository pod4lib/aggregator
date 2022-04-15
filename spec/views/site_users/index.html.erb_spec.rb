# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'site_users/index', type: :view do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  before do
    assign(:users, [user, admin])
    sign_in admin
  end

  it 'renders a list of users' do
    render
    assert_select 'tr>td', text: user.email
    assert_select 'tr>td', text: admin.email
  end

  it 'renders a button to add the admin role to the unprivileged user' do
    render
    expect(rendered).to have_link('', href: site_user_path(user, add_role: 'admin'))
  end

  it 'renders a button to remove the admin role from the admin user' do
    render
    expect(rendered).to have_link('', href: site_user_path(admin, remove_role: 'admin'))
  end
end
