# frozen_string_literal: true

# Service class for augmenting source MARC records with POD information
class AugmentMarcRecordService
  attr_reader :steps, :organization

  DEFAULT_STEPS = %i[
    append_pod_provenance_information
    append_normalized_item_information
  ].freeze

  def initialize(steps: nil, organization: nil)
    @steps = steps || DEFAULT_STEPS
    @organization = organization || Organization.new
  end

  # @param [MARC::Record] record to modify
  def execute(source_record)
    steps.each_with_object(duped_record(source_record)) do |step, record|
      send(step, record)
    end
  end

  private

  # Append a MARC 900$b containing the organization code of the organization that
  # provided the record to POD.
  # @param [MARC::Record] record to modify
  def append_pod_provenance_information(record)
    provenance_information = [pod_source_metadata, organization_metadata].compact_blank

    record.append(MARC::DataField.new('900', nil, nil, *provenance_information))
  end

  # Perform organization-specific/specified normalization steps
  # and add a $8 with a reference back to the source field (given as linking number = tag, sequence number = index)
  # @param [MARC::Record] record to modify
  def append_normalized_item_information(record)
    return if organization.normalization_steps.blank?

    organization.normalization_steps.each_value do |step|
      map_normalized_item_field(record, step)
    end
  end

  def map_normalized_item_field(record, step)
    record.fields(step['source_tag']).each.with_index do |field, index|
      subfield_data = map_subfield_data(field, step['subfields'])
      field_link = ['8', "#{field.tag}.#{index}\\p"]

      record.append(MARC::DataField.new(step['destination_tag'], nil, nil, pod_source_metadata, field_link, *subfield_data))
    end
  end

  def map_subfield_data(field, mapping)
    mapping.sort_by { |k, _v| k }.filter_map do |destination_subfield, source_subfield|
      [destination_subfield, field[source_subfield]] if source_subfield && field[source_subfield].present?
    end
  end

  def duped_record(source_record)
    MARC::Record.new_from_hash(source_record.to_hash)
  end

  def organization_metadata
    return [] if organization.code.blank?

    ['b', organization.code]
  end

  def pod_source_metadata
    %w[5 POD]
  end
end
