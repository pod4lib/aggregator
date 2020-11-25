class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:organization_id] = organization_context_id
    data[:token_id] = controller.current_token&.dig(0, 'jti') if controller.respond_to? :current_token
    super(data)
  end

  def organization_context_id
    return Organization.with_roles([:member, :owner], controller.current_user).first&.friendly_id if controller.current_user
    return controller.current_allowlisted_token&.organization&.friendly_id if controller.respond_to? :current_allowlisted_token
  end
end

# set to true for JavaScript tracking
Ahoy.api = true
Ahoy.mask_ips = true
Ahoy.track_bots = true # too aggressive (and unnecessary as we're tracking auth'ed events only)
Ahoy.geocode = false
