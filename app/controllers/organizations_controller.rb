# frozen_string_literal: true

# :nodoc:
class OrganizationsController < ApplicationController
  load_and_authorize_resource

  # We need unsafe_inline for Chartkick style_src (despite the nonce for script_src)
  # See https://github.com/ankane/chartkick/blob/master/guides/Content-Security-Policy.md
  content_security_policy only: :index do |policy|
    policy.style_src :self, :unsafe_inline
  end

  # GET /organizations
  # GET /organizations.json
  def index; end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    # make the org homepage for consumer orgs point to their org details default tab
    # see https://github.com/pod4lib/aggregator/issues/535#issuecomment-1103234114
    redirect_to organization_users_path(@organization) unless @organization.provider?

    @uploads = @organization.default_stream.uploads.active.order(created_at: :desc).page(params[:page])
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/normalized_data
  def normalized_data; end
  # GET /organizations/1/processing_status
  def processing_status; end

  # GET /organizations/1/provider_details
  def provider_details
    # consumer orgs don't have provider details; redirect to org details instead
    redirect_to organization_details_organization_path(@organization) unless @organization.provider?
  end

  # GET /organizations/1/organization_details
  def organization_details; end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_back_or_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { redirect_back_or_to @organization, alert: 'Organization could not be updated.' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def organization_params
    params.require(:organization)
          .permit(
            :name, :slug, :icon, :code, :provider,
            contact_email_attributes: %i[email],
            normalization_steps: [[:destination_tag, :source_tag, { subfields: %i[i a m] }]]
          )
  end
end
