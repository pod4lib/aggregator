# frozen_string_literal: true

# :nodoc:
class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def home
    # total providers and most recent upload
    @providers = Organization.where(provider: true).count
    @last_upload = Upload.order(created_at: :asc).last

    # total number of MARC records & unique records (by 001 field)
    @total_records = MarcRecord.count
    @unique_records = MarcRecord.select('DISTINCT marc001').count

    return if current_user.blank?

    # user's organization and most recent 3 files in its default stream
    @organization = current_user.organization
    @last_org_files = @organization.default_stream.files
                                   .limit(3)
                                   .reverse_order
                                   .flat_map(&:attachments)
  end

  def api; end

  def show
    render template: "pages/#{params[:id]}"
  end
end
