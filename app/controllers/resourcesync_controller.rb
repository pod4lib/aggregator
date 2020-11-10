# frozen_string_literal: true

# Produce more-or-less static resourcesync manifests
class ResourcesyncController < ApplicationController
  skip_authorization_check

  def source_description; end

  def capabilitylist; end

  def normalized_capabilitylist; end
end
