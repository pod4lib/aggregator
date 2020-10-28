require "administrate/base_dashboard"

class StreamDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    versions: Field::HasMany.with_options(class_name: "PaperTrail::Version"),
    organization: Field::BelongsTo,
    snapshots_attachments: Field::HasMany.with_options(class_name: "ActiveStorage::Attachment"),
    snapshots_blobs: Field::HasMany.with_options(class_name: "ActiveStorage::Blob"),
    id: Field::Number,
    name: Field::String,
    default: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    slug: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  versions
  organization
  snapshots_attachments
  snapshots_blobs
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  versions
  organization
  snapshots_attachments
  snapshots_blobs
  id
  name
  default
  created_at
  updated_at
  slug
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  versions
  organization
  snapshots_attachments
  snapshots_blobs
  name
  default
  slug
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how streams are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(stream)
  #   "Stream ##{stream.id}"
  # end
end
