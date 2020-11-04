# frozen_string_literal: true

namespace :agg do
  desc 'Create an initial admin user'
  task create_admin: :environment do
    puts 'Creating an initial admin user.'
    u = prompt_to_create_user

    u.add_role(:admin)
    u.confirm
    puts 'User created.'
  end

  def prompt_to_create_user
    User.find_or_create_by!(email: prompt_for_email) do |u|
      puts 'User not found. Enter a password to create the user.'
      u.password = prompt_for_password
    end
  rescue StandardError => e
    puts e
    retry
  end

  def prompt_for_email
    print 'Email: '
    $stdin.gets.chomp
  end

  def prompt_for_password
    begin
      system 'stty -echo'
      print 'Password (must be 8+ characters): '
      password = $stdin.gets.chomp
      puts "\n"
    ensure
      system 'stty echo'
    end
    password
  end
end
