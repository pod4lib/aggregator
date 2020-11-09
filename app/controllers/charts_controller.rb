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
end
