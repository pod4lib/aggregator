# frozen_string_literal: true

# Controller for managing access to organization data
class AllowedConsumersController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization

  # GET /organizations/1/access_restrictions
  def index
    @other_organizations = Organization.accessible_by(current_ability).where.not(id: @organization.id)
    @groups = Group.accessible_by(current_ability)
  end

  # POST /organizations/1/allowed_consumers/add_consumer
  def add_consumer
    authorize! :manage, @organization
    consumer_type = params[:consumer_type]
    consumer_id = params[:consumer_id]

    AllowedConsumer.find_or_create_by(
      organization: @organization,
      allowed_consumer_type: consumer_type,
      allowed_consumer_id: consumer_id
    )
    redirect_back fallback_location: organization_access_restrictions_path(id: @organization.id)
  end

  # DELETE /organizations/1/allowed_consumers/remove_consumer
  def remove_consumer
    authorize! :manage, @organization
    consumer_type = params[:consumer_type]
    consumer_id = params[:consumer_id]

    allowed_consumer = AllowedConsumer.find_by(
      organization: @organization,
      allowed_consumer_type: consumer_type,
      allowed_consumer_id: consumer_id
    )
    allowed_consumer.destroy if allowed_consumer.present?
    redirect_back fallback_location: organization_access_restrictions_path(id: @organization.id)
  end
end
