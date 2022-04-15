class DefaultStreamHistory < ApplicationRecord
  belongs_to :organization
  belongs_to :stream
end
