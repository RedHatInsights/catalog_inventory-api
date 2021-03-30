module Api
  module V1x0
    class SourcesController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin

      def refresh
        source = Source.find(params.require(:source_id))
        if source.availability_status == "available"
          SourceRefreshService.new(source).process
        else
          Rails.logger.info("Source #{source.id} is not available, starting availability check ...")
          task = CheckAvailabilityTaskService.new(:source_id => source.id).process.task
          task.dispatch
        end

        head :no_content
      rescue CatalogInventory::Exceptions::RecordLockedException, CatalogInventory::Exceptions::RefreshAlreadyRunningException => e
        render :json => {:message => e.message}, :status => :too_many_requests
      end
    end
  end
end
