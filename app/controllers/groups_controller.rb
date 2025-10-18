# frozen_string_literal: true

# Controller for managing organization groups
class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @groups = Group.all
    @organizations = Organization.all
  end

  def show
    @group = Group.friendly.find(params[:id])
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  def edit; end

  # POST /group
  # POST /group.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.', status: :see_other }
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
      if remove_organization || add_organization || update_group
        format.html { redirect_back_or_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { redirect_back_or_to @group, alert: 'Group could not be updated.' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group/1
  # DELETE /group/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def update_group
    return unless group_params

    @group.update(group_params)
  end

  def remove_organization
    return unless params[:remove_organization].present?

    @group.remove_organization params[:remove_organization]
  end

  def add_organization
    return unless params[:add_organization].present?

    @group.add_organization params[:add_organization]
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name, :short_name, :slug, :description, :icon)
  end
end
