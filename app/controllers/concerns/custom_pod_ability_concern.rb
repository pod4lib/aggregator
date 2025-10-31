# frozen_string_literal: true

##
# A concern to add the a custom current_ability
module CustomPodAbilityConcern
  def current_ability
    @current_ability ||= if current_token
                           TokenAbility.new(current_token)
                         else
                           Ability.new(current_user)
                         end
  end

  def current_token
    return unless jwt_token

    token = JWT.decode(
      jwt_token,
      Settings.jwt.secret,
      Settings.jwt.algorithm
    )

    token.first
  end

  def current_allowlisted_token
    return unless current_token

    if defined?(@current_allowlisted_token)
      @current_allowlisted_token
    else
      @current_allowlisted_token = AllowlistedJwt.find_by(jti: current_token.dig(0, 'jti'))
    end
  end
end
