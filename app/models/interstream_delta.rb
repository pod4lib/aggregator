class InterstreamDelta < ApplicationRecord
  belongs_to :normalized_dump

  has_one_attached :marc21
  has_one_attached :marcxml
  has_one_attached :deletes
end