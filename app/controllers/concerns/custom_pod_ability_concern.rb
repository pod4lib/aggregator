# frozen_string_literal: true

##
# A concern to add the a custom current_ability
module CustomPodAbilityConcern
  def current_ability
    @current_ability ||= Ability.new(current_user, current_token)
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
end
