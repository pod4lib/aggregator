# frozen_string_literal: true

# Controller for managing organization groups
class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @groups = Group.all
    @organizations = Organization.all
  end

  # POST /group
  # POST /group.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: t('.success'), status: :see_other }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /group/1
  # PATCH/PUT /group/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: t('.success') }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { redirect_back_or_to @group, alert: t('.error') }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group/1
  # DELETE /group/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t('.success'), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def group_params
    params.expect(group: [:name, :short_name, :slug, :description, :icon, { organization_ids: [] }])
  end
end
