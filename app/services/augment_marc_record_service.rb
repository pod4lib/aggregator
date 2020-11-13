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

  def execute(source_record)
    steps.each_with_object(duped_record(source_record)) do |step, record|
      send(step, record)
    end
  end

  private

  def append_pod_provenance_information(record)
    return if organization.code.blank?

    record.append(MARC::DataField.new('900', nil, nil, ['b', organization.code]))
  end

  def append_normalized_item_information(record)
    return if organization.normalization_steps.blank?

    organization.normalization_steps.each_value do |step|
      map_normalized_item_field(record, step)
    end
  end

  def map_normalized_item_field(record, step)
    record.fields(step['source_tag']).each do |field|
      subfield_data = step['subfields'].sort_by { |k, _v| k }.map do |destination_subfield, source_subfield|
        [destination_subfield, field[source_subfield]] if source_subfield && field[source_subfield].present?
      end.compact

      record.append(MARC::DataField.new(step['destination_tag'], nil, nil, *subfield_data))
    end
  end

  def duped_record(source_record)
    MARC::Record.new_from_hash(source_record.to_hash)
  end
end
