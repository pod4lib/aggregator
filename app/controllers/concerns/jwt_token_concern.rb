# frozen_string_literal: true

##
# Mixing concern to be added into controller contexts to
# allow for JWT Tokens to be parsed out of the AuthZ header
module JwtTokenConcern
  private

  def jwt_token
    type, token = request.headers['Authorization']&.split(' ')

    token if type == 'Bearer'
  end
end
