# frozen_string_literal: true

# :nodoc:
class ChartsController < ApplicationController
  skip_authorization_check

  def uploads
    render json: Upload.group_by_day(:created_at).count
  end

  def records
    render json: Statistic.where(resource_type: 'Organization').group_by_day(:created_at).sum(:unique_record_count)
  end

  def orgs
    authorize!(:show, :organization)
    @organization = Organization.find(params[:id])
    render json: @organization.uploads.map { |u| u.marc_profiles.map { |profile| { name: profile.blob.filename, data: profile.field_frequency } } }.flatten
    #.inject { |tot, n| tot.merge(n) { |k, a, b| a + b }}
  end
end
