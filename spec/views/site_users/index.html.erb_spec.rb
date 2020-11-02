# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'site_users/index', type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }

  before do
    assign(:users, [user, admin])
  end

  it 'renders a list of users' do
    render
    assert_select 'tr>td', text: user.email
    assert_select 'tr>td', text: admin.email
  end

  it 'renders a button to add the admin role to the unprivileged user' do
    render
    assert_select 'tbody > tr:first-child .btn', text: 'Add admin role' do
      assert_select '[data-method=?]', 'patch'
      assert_select '[href=?]', site_user_url(user, add_role: 'admin')
    end
  end

  it 'renders a button to remove the admin role from the admin user' do
    render
    assert_select 'tbody > tr:last-child .btn', text: 'Remove from admin role' do
      assert_select '[data-method=?]', 'patch'
      assert_select '[href=?]', site_user_url(admin, remove_role: 'admin')
    end
  end
end
