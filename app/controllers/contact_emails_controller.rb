# frozen_string_literal: true

# Contact email management
class ContactEmailsController < ApplicationController
  skip_before_action :authenticate_user!

  def confirm
    @contact_email = ContactEmail.find_by(confirmation_token: params[:token])
    authorize! :confirm, @contact_email

    respond_to do |format|
      if @contact_email.confirm!
        format.html { render_or_redirect_with_flash notice: 'The POD contact for this organization has been confirmed.' }
        format.json { head :no_content }
      else
        format.html { render_or_redirect_with_flash error: 'Unable to confirm contact email.' }
        format.json { render json: @contact_email.errors, status: :unprocessable_entity }
      end
    end
  end

  def render_or_redirect_with_flash(**messages)
    messages.each do |key, value|
      flash.keep[key] = value
    end

    if can? :read, @contact_email.organization
      redirect_to @contact_email.organization, status: :see_other
    else
      render 'confirm'
    end
  end
end
