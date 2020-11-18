# frozen_string_literal: true

##
# A concern to add the a custom current_ability
module CustomPodAbilityConcern
  def current_ability
    @current_ability ||= Ability.new(current_user, jwt_token)
  end
end
