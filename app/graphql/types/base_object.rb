# frozen_string_literal: true

module Types
  # :nodoc:
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField

    def current_ability
      @current_ability ||= context[:current_ability] || Ability.new
    end
  end
end
