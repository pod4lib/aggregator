# frozen_string_literal: true

# :nodoc:
class AllowlistedJwtsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization
  authorize_resource class: :controller

  # GET /organizations/1/allowlisted_jwts
  # GET /organizations/1/allowlisted_jwts.json
  def index; end

  # GET /organizations/1/allowlisted_jwts/new
  def new; end

  # POST /organizations/1/allowlisted_jwts
  # POST /organizations/1/allowlisted_jwts/2.json
  def create
    respond_to do |format|
      if @allowlisted_jwt.save
        format.html { redirect_to organization_allowlisted_jwts_path(@organization), notice: 'Token was successfully created.' }
        format.json { render :show, status: :created, location: [@organization, @allowlisted_jwt] }
      else
        format.html { render :new }
        format.json { render json: @allowlisted_jwt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1/allowlisted_jwts/2
  # DELETE /organizations/1/allowlisted_jwts/2.json
  def destroy
    @allowlisted_jwt.destroy

    respond_to do |format|
      format.html { redirect_to organization_allowlisted_jwts_path(@organization), notice: 'Token was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def allowlisted_jwt_params
    return {} unless params.key? :allowlisted_jwt

    params.require(:allowlisted_jwt).permit(:label, :scope)
  end
end
