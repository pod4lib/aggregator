# frozen_string_literal: true

json.array! @uploads, partial: 'uploads/upload', as: :upload
