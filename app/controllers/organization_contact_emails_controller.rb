# frozen_string_literal: true

# Contact emails for the organization
class OrganizationContactEmailsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource :contact_email, through: :organization, parent: false, except: [:confirm]

  def new; end

  def create
    respond_to do |format|
      if @contact_email.save
        format.html { redirect_to @organization, notice: 'Contact email was successfully created.' }
        format.json { render :show, status: :created, location: [@organization, @contact_email] }
      else
        format.html { render :new }
        format.json { render json: @contact_email.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact_email.destroy

    respond_to do |format|
      format.html { redirect_to organization_url(@organization), notice: 'Contact email was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def contact_email_params
    params.require(:contact_email).permit(:email)
  end
end
