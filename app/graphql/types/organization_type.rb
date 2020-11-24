# frozen_string_literal: true

module Types
  # :nodoc:
  class OrganizationType < Types::BaseObject
    include Types::MarcRecordsQuery

    field :slug, ID, null: true
    field :name, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :slug, String, null: true
    field :last_delta_dump_at, GraphQL::Types::ISO8601DateTime, null: true
    field :code, String, null: true
    # field :normalization_steps, Types::JsonType, null: true
    field :public, Boolean, null: true
    field :name, String, null: true
    field :records, [MarcRecordType], null: true do
      description 'Return all MARC records'
      argument :filter, [String], required: false
      argument :limit, Integer, required: false
    end

    def records(limit: 25, **args, &block)
      return to_enum(:records, **args, limit: limit) unless block

      with_limit(limit, :filter_records, organization: object, **args, &block)
    end
  end
end
