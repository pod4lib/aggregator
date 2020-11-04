Rack::Attack.throttle("registers/ip", limit: 10, period: 12.hours) do |req|
  req.ip if req.post? && req.path.start_with?("/users/sign_up")
end

Rack::Attack.throttle("logins/ip", limit: 10, period: 12.hours) do |req|
  req.ip if req.post? && req.path.start_with?("/users/sign_in")
end

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  puts "Throttled #{req.env["rack.attack.match_discriminator"]}"
end
