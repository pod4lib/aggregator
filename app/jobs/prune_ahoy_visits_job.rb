# frozen_string_literal: true

##
# Background job to prune ahoy jobs
class PruneAhoyVisitsJob < ApplicationJob
  def perform
    started_at = Ahoy::Visit.arel_table[:started_at]
    Ahoy::Visit.where(started_at.lt(180.days.ago)).where.missing(:events).in_batches do |visits|
      visits.delete_all
      sleep(5) # Throttle the delete queries
    end
  end
end
