# frozen_string_literal: true

module Types
  # :nodoc:
  class QueryType < Types::BaseObject
    include Types::MarcRecordsQuery
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :organizations, [OrganizationType], null: false do
      description 'List all organizations'
    end

    field :organization, OrganizationType, null: false do
      description 'Find an organization by ID'
      argument :id, ID, required: true
    end

    field :records, [MarcRecordType], null: false do
      description 'List all marc records'
      argument :filter, [String], required: false
      argument :limit, Integer, required: false
    end

    def organization(id:)
      Organization.accessible_by(current_ability).friendly.find(id)
    end

    def organizations
      Organization.accessible_by(current_ability)
    end

    def records(limit: 25, **args, &block)
      return to_enum(:records, **args, limit: limit) unless block

      with_limit(limit, :filter_records, **args, &block)
    end
  end
end
